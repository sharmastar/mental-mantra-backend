import { IsString, IsOptional, IsInt, Min, Max, IsBoolean, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateUrgeDto {
  @ApiPropertyOptional({ example: 'Stress at work' })
  @IsOptional()
  @IsString()
  trigger?: string;

  @ApiProperty({ example: 7 })
  @IsInt()
  @Min(1)
  @Max(10)
  intensity: number;

  @ApiProperty({ example: 'Screen Time' })
  @IsString()
  @IsNotEmpty()
  urgeType: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  resisted?: boolean;

  @ApiPropertyOptional({ example: 'Deep breathing for 5 minutes' })
  @IsOptional()
  @IsString()
  copingStrategy?: string;

  @ApiPropertyOptional({ example: 'Felt an urge but stayed strong' })
  @IsOptional()
  @IsString()
  notes?: string;
}
