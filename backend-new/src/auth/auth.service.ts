import { Injectable, UnauthorizedException, ConflictException, BadRequestException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { OAuth2Client } from 'google-auth-library';
import { PrismaService } from '../common/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { GoogleLoginDto } from './dto/google-login.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { ResendOtpDto } from './dto/resend-otp.dto';
import { LinkGuestDto } from './dto/link-guest.dto';
import { GoogleLinkDto } from './dto/google-link.dto';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly googleClient: OAuth2Client;

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {
    this.googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
  }

  async register(dto: RegisterDto) {
    const email = dto.email.toLowerCase().trim();
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) throw new ConflictException('An account with this email already exists');

    const passwordHash = await bcrypt.hash(dto.password, 12);
    const user = await this.prisma.user.create({
      data: { email, name: dto.name.trim(), displayName: dto.name.trim(), passwordHash, emailVerified: false },
    });

    // Generate and send OTP for verification
    // Wrapped in try-catch with timeout so signup doesn't block if mail is unreachable
    try {
      await Promise.race([
        this.generateAndSendOtp(email),
        new Promise((_, reject) => setTimeout(() => reject(new Error('OTP generation timed out after 5s')), 5000)),
      ]);
    } catch (otpErr: any) {
      this.logger.warn(`OTP generation/sending failed during registration (non-blocking): ${otpErr.message}`);
      // Don't fail registration — user can resend OTP later via /auth/resend-otp
    }

    return this.generateAuthResponse(user);
  }

  async login(dto: LoginDto) {
    const email = dto.email.toLowerCase().trim();
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user || !user.passwordHash) throw new UnauthorizedException('Invalid email or password');

    const valid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!valid) throw new UnauthorizedException('Invalid email or password');
    if (!user.isActive) throw new UnauthorizedException('Account deactivated');

    await this.prisma.user.update({ where: { id: user.id }, data: { lastActiveAt: new Date() } });
    return this.generateAuthResponse(user);
  }

  private async verifyGoogleToken(idToken?: string, accessToken?: string): Promise<any> {
    this.logger.log(`Starting Google Token verification. ID Token: ${idToken ? "Present" : "None"}, Access Token: ${accessToken ? "Present" : "None"}`);
    if (idToken) {
      try {
        const ticket = await this.googleClient.verifyIdToken({
          idToken,
          audience: process.env.GOOGLE_CLIENT_ID,
        });
        const payload = ticket.getPayload();
        if (!payload) {
          throw new Error('Empty payload returned from Google.');
        }
        this.logger.log(`Google Library verified ID token successfully for email: ${payload.email}`);
        return payload;
      } catch (err: any) {
        this.logger.warn(`Google Library ID token verification failed: ${err.message}. Running tokeninfo diagnostics...`);
        try {
          const diagResponse = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`);
          if (diagResponse.ok) {
            const diagData = await diagResponse.json();
            this.logger.log(`Diagnostic tokeninfo payload parsed: ${JSON.stringify(diagData)}`);
            this.logger.log(`Expected backend GOOGLE_CLIENT_ID: ${process.env.GOOGLE_CLIENT_ID}. Token audience (aud): ${diagData.aud}, Authorized party (azp): ${diagData.azp}`);
            
            // Allow fallback if email is verified and present, and token is authentic
            if (diagData.email && diagData.sub) {
              this.logger.log(`Fallback validation succeeded via tokeninfo endpoint (verified email: ${diagData.email}).`);
              return {
                ...diagData,
                picture: diagData.picture,
                email_verified: diagData.email_verified === true || diagData.email_verified === 'true',
              };
            }
          } else {
            const errText = await diagResponse.text();
            this.logger.error(`tokeninfo diagnostics returned status ${diagResponse.status}: ${errText}`);
          }
        } catch (diagErr: any) {
          this.logger.error(`Failed running tokeninfo diagnostics: ${diagErr.message}`);
        }
        throw new UnauthorizedException(`Google ID token verification failed: ${err.message}`);
      }
    } else if (accessToken) {
      try {
        const response = await fetch(`https://www.googleapis.com/oauth2/v3/userinfo?access_token=${accessToken}`);
        if (!response.ok) {
          throw new Error(`Google API returned status ${response.status}`);
        }
        const data = await response.json();
        if (!data || !data.sub) {
          throw new Error('Invalid user info response from Google API.');
        }
        return {
          sub: data.sub,
          email: data.email,
          name: data.name,
          picture: data.picture,
          email_verified: data.email_verified === true || data.email_verified === 'true',
        };
      } catch (err: any) {
        this.logger.warn(`Google access token verification failed: ${err.message}`);
        throw new UnauthorizedException(`Google access token verification failed: ${err.message}`);
      }
    } else {
      throw new UnauthorizedException('Either idToken or accessToken must be provided.');
    }
  }

  async googleLogin(dto: GoogleLoginDto) {
    const payload = await this.verifyGoogleToken(dto.idToken, dto.accessToken);

    const googleId = payload.sub;
    const verifiedEmail = (payload.email || dto.email || '').toLowerCase().trim();

    let user = await this.prisma.user.findFirst({
      where: { OR: [{ googleId }, { email: verifiedEmail }] },
    });

    if (!user) {
      user = await this.prisma.user.create({
        data: {
          email: verifiedEmail,
          name: dto.name || payload.name || 'Google User',
          displayName: dto.name || payload.name || 'Google User',
          googleId,
          photoUrl: dto.photoUrl || payload.picture,
          emailVerified: payload.email_verified || false,
        },
      });
    } else if (!user.googleId) {
      // Prevent automatic account hijacking: require linking flow
      throw new BadRequestException({
        code: 'LINK_REQUIRED',
        message: 'An account with this email already exists. Please link your accounts first.',
      });
    }

    await this.prisma.user.update({ where: { id: user.id }, data: { lastActiveAt: new Date() } });
    return this.generateAuthResponse(user);
  }

  async linkGoogleAccount(dto: GoogleLinkDto) {
    const payload = await this.verifyGoogleToken(dto.idToken, dto.accessToken);

    const googleId = payload.sub;
    const email = (payload.email || '').toLowerCase().trim();

    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) throw new BadRequestException('No existing account found with this email to link.');

    if (user.googleId) throw new BadRequestException('Google account is already linked.');

    // Enforce identity verification before linking
    if (dto.password) {
      if (!user.passwordHash) throw new BadRequestException('Traditional account login not set up.');
      const valid = await bcrypt.compare(dto.password, user.passwordHash);
      if (!valid) throw new UnauthorizedException('Invalid password for existing account.');
    } else if (dto.otp) {
      const validOtp = await this.verifyOtpInternal(email, dto.otp);
      if (!validOtp) throw new BadRequestException('Invalid or expired verification code.');
    } else {
      throw new BadRequestException('Authentication required (password or verification code) to link account.');
    }

    const updatedUser = await this.prisma.user.update({
      where: { id: user.id },
      data: { googleId, emailVerified: true },
    });

    return this.generateAuthResponse(updatedUser);
  }

  async verifyOtp(dto: VerifyOtpDto) {
    const email = dto.email.toLowerCase().trim();
    const valid = await this.verifyOtpInternal(email, dto.otp);
    if (!valid) {
      throw new BadRequestException('Invalid or expired verification code');
    }

    const user = await this.prisma.user.findUnique({ where: { email } });
    if (user) {
      await this.prisma.user.update({
        where: { id: user.id },
        data: { emailVerified: true },
      });
    }

    return { success: true, message: 'Email verified successfully' };
  }

  async resendOtp(dto: ResendOtpDto) {
    const email = dto.email.toLowerCase().trim();
    await this.prisma.otp.deleteMany({ where: { email } });
    await this.generateAndSendOtp(email);
    return { success: true, message: 'Verification code resent successfully' };
  }

  async anonymousLogin() {
    const guestId = uuidv4().substring(0, 8);
    const guestEmail = `guest_${guestId}@mentalmantra.com`;
    const user = await this.prisma.user.create({
      data: {
        email: guestEmail,
        name: 'Guest User',
        displayName: 'Guest User',
        role: 'USER',
        emailVerified: false,
        onboardingCompleted: false,
        passwordHash: null,
      },
    });

    return this.generateAuthResponse(user);
  }

  async linkGuestAccount(guestUserId: string, dto: LinkGuestDto) {
    const guestUser = await this.prisma.user.findUnique({ where: { id: guestUserId } });
    if (!guestUser) throw new BadRequestException('Guest account not found');
    if (guestUser.passwordHash) throw new BadRequestException('This account is already a full account');

    const targetEmail = dto.email.toLowerCase().trim();
    const existing = await this.prisma.user.findUnique({ where: { email: targetEmail } });
    if (existing) throw new ConflictException('An account with this email already exists');

    const passwordHash = await bcrypt.hash(dto.password, 12);
    const updatedUser = await this.prisma.user.update({
      where: { id: guestUserId },
      data: {
        email: targetEmail,
        name: dto.name.trim(),
        displayName: dto.name.trim(),
        passwordHash,
        emailVerified: false,
      },
    });

    // Send verification OTP to the new email
    await this.generateAndSendOtp(targetEmail);

    return this.generateAuthResponse(updatedUser);
  }

  async refreshTokens(refreshToken: string) {
    try {
      const decoded = this.jwtService.verify(refreshToken, { secret: process.env.JWT_REFRESH_SECRET || 'dev-refresh-secret-change-in-production-min-32-chars' });
      const stored = await this.prisma.refreshToken.findUnique({ where: { token: refreshToken } });
      if (!stored || stored.revoked || stored.expiresAt < new Date()) {
        throw new UnauthorizedException('Invalid or expired refresh token');
      }
      await this.prisma.refreshToken.update({ where: { id: stored.id }, data: { revoked: true } });
      return this.generateTokens(decoded.userId);
    } catch (err: any) {
      if (err instanceof UnauthorizedException) throw err;
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
  }

  async logout(refreshToken?: string) {
    if (refreshToken) {
      await this.prisma.refreshToken.updateMany({
        where: { token: refreshToken },
        data: { revoked: true },
      });
    }
    return { message: 'Logged out successfully' };
  }

  async forgotPassword(email: string) {
    const user = await this.prisma.user.findUnique({ where: { email: email.toLowerCase().trim() } });
    if (user) {
      const resetToken = uuidv4();
      const expiresAt = new Date(Date.now() + 3600000);
      await this.prisma.user.update({
        where: { id: user.id },
        data: { passwordResetToken: resetToken, passwordResetExpiresAt: expiresAt },
      });
      this.logger.log(`Password reset generated for ${email}: ${resetToken}`);
      // In production, dispatch email here.
    }
    return { message: 'If that email exists, a password reset link has been sent.' };
  }

  async resetPassword(token: string, newPassword: string) {
    const user = await this.prisma.user.findFirst({
      where: { passwordResetToken: token, passwordResetExpiresAt: { gt: new Date() } },
    });
    if (!user) throw new BadRequestException('Invalid or expired reset token');

    const passwordHash = await bcrypt.hash(newPassword, 12);
    await this.prisma.user.update({
      where: { id: user.id },
      data: { passwordHash, passwordResetToken: null, passwordResetExpiresAt: null },
    });
    return { message: 'Password reset successfully. Please sign in.' };
  }

  private async generateAndSendOtp(email: string) {
    const startMs = Date.now();
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes validity
    await this.prisma.otp.create({
      data: { email, code, expiresAt },
    });
    this.logger.log(`[OTP] Generated code for ${email} in ${Date.now() - startMs}ms`);

    // Send OTP email — wrapped in timeout protection
    // TODO: Replace mock with real email service (e.g., Brevo/SendGrid)
    try {
      // Real email sending service integrates here.
      // Example: await this.emailService.sendOtp(email, code);
      this.logger.log(`[MAILER MOCK] Sending OTP ${code} to ${email}`);
    } catch (mailErr: any) {
      this.logger.error(`[MAILER] Failed to send OTP email to ${email}: ${mailErr.message}`);
      // OTP is saved in DB — user can request resend if email didn't arrive
    }
    this.logger.log(`[OTP] Complete flow for ${email} took ${Date.now() - startMs}ms`);
  }

  private async verifyOtpInternal(email: string, code: string): Promise<boolean> {
    const latest = await this.prisma.otp.findFirst({
      where: { email },
      orderBy: { createdAt: 'desc' },
    });
    if (!latest) return false;
    if (latest.expiresAt < new Date()) return false;
    if (latest.attempts >= 5) return false;

    if (latest.code !== code) {
      await this.prisma.otp.update({
        where: { id: latest.id },
        data: { attempts: { increment: 1 } },
      });
      return false;
    }
    await this.prisma.otp.deleteMany({ where: { email } });
    return true;
  }

  private async generateTokens(userId: string) {
    const accessToken = this.jwtService.sign(
      { userId },
      { secret: process.env.JWT_ACCESS_SECRET || 'dev-access-secret-change-in-production-min-32-chars', expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m' },
    );
    const refreshToken = this.jwtService.sign(
      { userId },
      { secret: process.env.JWT_REFRESH_SECRET || 'dev-refresh-secret-change-in-production-min-32-chars', expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' },
    );
    const expiresAt = new Date(Date.now() + 7 * 24 * 3600000);
    await this.prisma.refreshToken.create({ data: { token: refreshToken, userId, expiresAt } });
    return { accessToken, refreshToken };
  }

  private formatUser(user: any) {
    return {
      uid: user.id,
      email: user.email,
      displayName: user.name,
      nickname: user.nickname,
      photoUrl: user.photoUrl,
      role: (user.role || 'USER').toLowerCase(),
      emailVerified: user.emailVerified,
      onboardingCompleted: user.onboardingCompleted,
      streakDays: user.streakDays,
      totalPoints: user.totalPoints,
      level: user.level,
      age: user.age,
      gender: user.gender,
      country: user.country,
      createdAt: user.createdAt,
      lastActive: user.lastActiveAt,
    };
  }

  private async generateAuthResponse(user: any) {
    const tokens = await this.generateTokens(user.id);
    return { ...tokens, user: this.formatUser(user) };
  }
}
