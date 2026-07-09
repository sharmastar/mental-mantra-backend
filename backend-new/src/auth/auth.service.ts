import { Injectable, UnauthorizedException, ConflictException, BadRequestException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { OAuth2Client } from 'google-auth-library';
import { PrismaService } from '../common/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { GoogleLoginDto } from './dto/google-login.dto';

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
      data: { email, name: dto.name.trim(), displayName: dto.name.trim(), passwordHash },
    });

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

  async googleLogin(dto: GoogleLoginDto) {
    let payload: any;
    try {
      const ticket = await this.googleClient.verifyIdToken({
        idToken: dto.idToken,
        audience: process.env.GOOGLE_CLIENT_ID,
      });
      payload = ticket.getPayload();
    } catch (err: any) {
      this.logger.warn(`Google token verification failed: ${err.message}`);
      throw new UnauthorizedException(`Google token verification failed: ${err.message}`);
    }

    const googleId = payload.sub;
    const verifiedEmail = payload.email || dto.email;

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
      user = await this.prisma.user.update({
        where: { id: user.id },
        data: { googleId, emailVerified: true, photoUrl: dto.photoUrl || user.photoUrl },
      });
    }

    await this.prisma.user.update({ where: { id: user.id }, data: { lastActiveAt: new Date() } });
    return this.generateAuthResponse(user);
  }

  async refreshTokens(refreshToken: string) {
    try {
      const decoded = this.jwtService.verify(refreshToken, { secret: process.env.JWT_REFRESH_SECRET });
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

  private async generateTokens(userId: string) {
    const accessToken = this.jwtService.sign(
      { userId },
      { secret: process.env.JWT_ACCESS_SECRET, expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m' },
    );
    const refreshToken = this.jwtService.sign(
      { userId },
      { secret: process.env.JWT_REFRESH_SECRET, expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' },
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
