import { IsString, IsOptional, IsInt, Min, Max, IsArray, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateJournalDto {
  @ApiPropertyOptional({ example: 'My Morning Reflection' })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiProperty({ example: 'Today I woke up feeling very rested and did some stretching...' })
  @IsString()
  @IsNotEmpty()
  content: string;

  @ApiPropertyOptional({ example: 4 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  mood?: number;

  @ApiPropertyOptional({ example: '😊' })
  @IsOptional()
  @IsString()
  moodEmoji?: string;

  @ApiPropertyOptional({ example: ['mindfulness', 'morning'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];
}
