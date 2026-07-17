import { IsString, IsOptional, IsInt, Min, Max, IsArray, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateMoodDto {
  @ApiProperty({ example: 4 })
  @IsInt()
  @Min(1)
  @Max(5)
  mood: number;

  @ApiPropertyOptional({ example: '😊' })
  @IsOptional()
  @IsString()
  emoji?: string;

  @ApiProperty({ example: 'Happy' })
  @IsString()
  @IsNotEmpty()
  label: string;

  @ApiPropertyOptional({ example: 'Felt good after journaling.' })
  @IsOptional()
  @IsString()
  note?: string;

  @ApiPropertyOptional({ example: ['social', 'hobbies'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];
}
