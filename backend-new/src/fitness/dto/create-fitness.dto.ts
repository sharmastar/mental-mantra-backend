import { IsString, IsOptional, IsInt, Min, IsDateString, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateFitnessDto {
  @ApiProperty({ example: 'Running' })
  @IsString()
  @IsNotEmpty()
  activity: string;

  @ApiProperty({ example: 30 })
  @IsInt()
  @Min(1)
  durationMin: number;

  @ApiPropertyOptional({ example: 250 })
  @IsOptional()
  @IsInt()
  @Min(0)
  calories?: number;

  @ApiPropertyOptional({ example: 'Cardio training.' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ example: '2026-07-16T00:00:00.000Z' })
  @IsDateString()
  date: string;
}
