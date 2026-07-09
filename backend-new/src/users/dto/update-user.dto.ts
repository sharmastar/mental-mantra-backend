import { IsString, IsOptional, IsInt, IsBoolean } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateUserDto {
  @ApiPropertyOptional() @IsOptional() @IsString() name?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() nickname?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() photoUrl?: string;
  @ApiPropertyOptional() @IsOptional() @IsInt() age?: number;
  @ApiPropertyOptional() @IsOptional() @IsString() gender?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() country?: string;
}

export class OnboardingDto {
  @ApiPropertyOptional() @IsOptional() @IsString() nickname?: string;
  @ApiPropertyOptional() @IsOptional() @IsInt() age?: number;
  @ApiPropertyOptional() @IsOptional() @IsString() gender?: string;
  @ApiPropertyOptional() @IsOptional() @IsString({ each: true }) goals?: string[];
  @ApiPropertyOptional() @IsOptional() @IsString() primaryChallenge?: string;
}

export class FcmTokenDto {
  @IsString() token: string;
}
