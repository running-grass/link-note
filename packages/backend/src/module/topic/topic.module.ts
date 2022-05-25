import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Topic } from '../../entity/topic.entity';
import { NodeService } from './node.service';
import { TopicController } from './topic.controller';
import { TopicResolver } from './topic.resolver';
import { TopicService } from './topic.service';
import { Node } from '../../entity/node.entity'
import { CardModule } from 'src/module/card/card.module';
@Module({
  imports: [TypeOrmModule.forFeature([Topic, Node]), CardModule],
  providers: [TopicService, TopicResolver, NodeService],
  controllers: [TopicController],
  exports: [TopicService, NodeService,TypeOrmModule]
})
export class TopicModule {}