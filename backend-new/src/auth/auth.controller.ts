import { Controller, Post, Body, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshDto } from './dto/refresh.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { GoogleLoginDto } from './dto/google-login.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { ResendOtpDto } from './dto/resend-otp.dto';
import { LinkGuestDto } from './dto/link-guest.dto';
import { GoogleLinkDto } from './dto/google-link.dto';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @ApiOperation({ summary: 'Register a new user' })
  async register(@Body() dto: RegisterDto) {
    return { success: true, message: 'Account created successfully. Please verify your email.', ...await this.authService.register(dto) };
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  @ApiOperation({ summary: 'Login with email and password' })
  async login(@Body() dto: LoginDto) {
    return { success: true, message: 'Login successful', ...await this.authService.login(dto) };
  }

  @Post('google')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @ApiOperation({ summary: 'Sign in with Google' })
  async googleLogin(@Body() dto: GoogleLoginDto) {
    return { success: true, message: 'Google sign-in successful', ...await this.authService.googleLogin(dto) };
  }

  @Post('google/link')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @ApiOperation({ summary: 'Link Google identity to existing account securely' })
  async linkGoogle(@Body() dto: GoogleLinkDto) {
    return { success: true, message: 'Account linked successfully', ...await this.authService.linkGoogleAccount(dto) };
  }

  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @ApiOperation({ summary: 'Verify email with OTP code' })
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    return await this.authService.verifyOtp(dto);
  }

  @Post('resend-otp')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 3, ttl: 60000 } })
  @ApiOperation({ summary: 'Resend verification OTP' })
  async resendOtp(@Body() dto: ResendOtpDto) {
    return await this.authService.resendOtp(dto);
  }

  @Post('anonymous')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Sign in anonymously as guest' })
  async anonymousLogin() {
    return { success: true, message: 'Anonymous session established', ...await this.authService.anonymousLogin() };
  }

  @Post('link-guest')
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Convert guest session to permanent email account' })
  async linkGuest(@CurrentUser('id') guestUserId: string, @Body() dto: LinkGuestDto) {
    return { success: true, message: 'Guest account linked successfully. Please verify your email.', ...await this.authService.linkGuestAccount(guestUserId, dto) };
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Refresh access token' })
  async refresh(@Body() dto: RefreshDto) {
    const result = await this.authService.refreshTokens(dto.refreshToken);
    return { success: true, ...result };
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Logout and revoke refresh token' })
  async logout(@Body() dto: RefreshDto) {
    return { success: true, ...await this.authService.logout(dto?.refreshToken) };
  }

  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 3, ttl: 60000 } })
  @ApiOperation({ summary: 'Request password reset' })
  async forgotPassword(@Body() dto: ForgotPasswordDto) {
    return { success: true, ...await this.authService.forgotPassword(dto.email) };
  }

  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 3, ttl: 60000 } })
  @ApiOperation({ summary: 'Reset password with token' })
  async resetPassword(@Body() dto: ResetPasswordDto) {
    return { success: true, ...await this.authService.resetPassword(dto.token, dto.newPassword) };
  }
}
