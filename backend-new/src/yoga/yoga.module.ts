import { Module } from '@nestjs/common';
import { YogaController } from './yoga.controller';
import { YogaService } from './yoga.service';

@Module({ controllers: [YogaController], providers: [YogaService] })
export class YogaModule {}
