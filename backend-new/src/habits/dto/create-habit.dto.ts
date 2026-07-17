import { IsString, IsOptional, IsInt, Min, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateHabitDto {
  @ApiProperty({ example: 'Meditation' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({ example: 'Daily morning meditation for 10 minutes.' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: 'self_improvement' })
  @IsOptional()
  @IsString()
  icon?: string;

  @ApiPropertyOptional({ example: '0xFF1E9B8E' })
  @IsOptional()
  @IsString()
  color?: string;

  @ApiPropertyOptional({ example: 'daily' })
  @IsOptional()
  @IsString()
  frequency?: string;

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @IsInt()
  @Min(1)
  targetCount?: number;
}
