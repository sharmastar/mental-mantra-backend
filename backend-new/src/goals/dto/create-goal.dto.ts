import { IsString, IsOptional, IsInt, Min, IsNotEmpty, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateGoalDto {
  @ApiProperty({ example: 'Read more books' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({ example: 'Read at least 12 books this year.' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ example: 'Learning' })
  @IsString()
  @IsNotEmpty()
  category: string;

  @ApiProperty({ example: 12 })
  @IsInt()
  @Min(1)
  targetValue: number;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  currentValue?: number;

  @ApiPropertyOptional({ example: '2026-12-31T23:59:59.999Z' })
  @IsOptional()
  @IsDateString()
  deadline?: string;
}
