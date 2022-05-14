import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Topic } from '../entity/topic.entity';
import { NodeDtoSort, Order } from '../graphql';
@Injectable()
export class TopicService {
  constructor(
    @InjectRepository(Topic)
    private topicRepository: Repository<Topic>
  ) {}

  findAll(sort: NodeDtoSort = NodeDtoSort.createDate, order: Order = Order.DESC, limit: number = 100): Promise<Topic[]> {
    // return this.topicRepository.find();
    return this.topicRepository
              .createQueryBuilder('topic')
                .orderBy('topic.' + sort, order)
                .limit(limit)
                .getMany();
  }

  newOne(title: string): Promise<Topic> {
      const t = new Topic();
      t.title = title
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