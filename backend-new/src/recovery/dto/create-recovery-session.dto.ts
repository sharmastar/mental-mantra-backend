import { IsString, IsInt, Min, IsOptional, IsDateString, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateRecoverySessionDto {
  @ApiProperty({ example: 'Digital Detox' })
  @IsString()
  @IsNotEmpty()
  sessionType: string;

  @ApiProperty({ example: 45 })
  @IsInt()
  @Min(1)
  durationMin: number;

  @ApiPropertyOptional({ example: '2026-07-16T00:00:00.000Z' })
  @IsOptional()
  @IsDateString()
  startedAt?: string;
}
