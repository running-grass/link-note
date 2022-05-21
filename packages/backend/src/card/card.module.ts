import { forwardRef, Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Card } from 'src/entity/card.entity';
import { TopicModule } from 'src/topic/topic.module';
import { CardResolver } from './card.resolver';
import { CardService } from './card.service';

@Module({
  imports: [TypeOrmModule.forFeature([Card]), forwardRef(() => TopicModule)],
  providers: [CardService, CardResolver],
  controllers: [],
  exports: [TypeOrmModule, CardService]
})
export class CardModule {}