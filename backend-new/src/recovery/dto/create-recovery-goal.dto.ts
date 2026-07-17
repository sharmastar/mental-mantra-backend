import { IsString, IsInt, Min, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateRecoveryGoalDto {
  @ApiProperty({ example: 'Urge Resistance' })
  @IsString()
  @IsNotEmpty()
  targetType: string;

  @ApiProperty({ example: 30 })
  @IsInt()
  @Min(1)
  targetValue: number;
}
