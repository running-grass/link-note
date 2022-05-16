import { Controller, Get, Param, Post } from '@nestjs/common';
import { Topic } from '../entity/topic.entity';
import { TopicService } from './topic.service';

@Controller('topic')
export class TopicController {
  constructor(private readonly topicService: TopicService) {}

  // @Get()
  // async getAll(): Promise<Topic[]> {
  //   // return this.topicService.findAll();
  // }

  @Post('new/:title')
  async newOne(@Param('title') title : string) {
      return this.topicService.newOne(title);
  }
}
