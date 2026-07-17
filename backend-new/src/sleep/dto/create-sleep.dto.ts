import { IsString, IsOptional, IsInt, Min, Max, IsDateString, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateSleepDto {
  @ApiProperty({ example: '2026-07-15T22:00:00.000Z' })
  @IsDateString()
  bedtime: string;

  @ApiProperty({ example: '2026-07-16T06:00:00.000Z' })
  @IsDateString()
  wakeTime: string;

  @ApiPropertyOptional({ example: 4 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  quality?: number;

  @ApiPropertyOptional({ example: 'Slept soundly, woke up feeling refreshed.' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ example: '2026-07-16T00:00:00.000Z' })
  @IsDateString()
  date: string;
}
