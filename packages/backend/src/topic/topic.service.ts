import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Topic } from '../entity/topic.entity';

@Injectable()
export class TopicService {
  constructor(
    @InjectRepository(Topic)
    private topicRepository: Repository<Topic>
  ) {}

  findAll(): Promise<Topic[]> {
    return this.topicRepository.find();
  }

  newOne(): Promise<Topic> {
      const t = new Topic();
      t.title = "abcdef"
      return this.topicRepository.save(t);
  }
  
  findOneById(id: number) {
    return this.topicRepository.findOneBy({id: id});
  }

//   findOne(id: string): Promise<Topic> {
//     return this.topicRepository.findOne(id);
//   }

//   async remove(id: string): Promise<void> {
//     await this.topicRepository.delete(id);
//   }
}