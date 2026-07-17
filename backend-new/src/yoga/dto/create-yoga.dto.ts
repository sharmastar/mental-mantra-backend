import { IsString, IsOptional, IsInt, Min, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateYogaDto {
  @ApiProperty({ example: 'Morning Vinyasa Flow' })
  @IsString()
  @IsNotEmpty()
  sessionName: string;

  @ApiPropertyOptional({ example: 'Vinyasa' })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiProperty({ example: 20 })
  @IsInt()
  @Min(1)
  durationMin: number;
}
