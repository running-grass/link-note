import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Topic } from '../entity/topic.entity';
import { TopicController } from './topic.controller';
import { TopicResolver } from './topic.resolver';
import { TopicService } from './topic.service';

@Module({
  imports: [TypeOrmModule.forFeature([Topic])],
  providers: [TopicService, TopicResolver],
  controllers: [TopicController],
})
export class TopicModule {}