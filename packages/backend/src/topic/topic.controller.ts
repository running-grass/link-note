import { Controller, Get, Post } from '@nestjs/common';
import { Topic } from '../entity/topic.entity';
import { TopicService } from './topic.service';

@Controller('topic')
export class TopicController {
  constructor(private readonly topicService: TopicService) {}

  @Get()
  async getAll(): Promise<Topic[]> {
    return this.topicService.findAll();
  }

  @Post('new')
  async newOne() {
      return this.topicService.newOne();
  }
}
