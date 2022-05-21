import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Topic } from '../entity/topic.entity';
import { BaseSort, Order } from '../enum/common'
@Injectable()
export class TopicService {

  constructor(
    @InjectRepository(Topic)
    private topicRepository: Repository<Topic>
  ) {}

  findAll(sort: BaseSort = BaseSort.id
        , order: Order = Order.DESC
        , limit: number = 10
        , search: string): Promise<Topic[]> {

    let build = this.topicRepository   .createQueryBuilder('topic');

    // 字符串匹配
    if (search) {
      build = build.where("topic.title like :keyword", { keyword: `%${search}%`});
    }

    return build.orderBy(`topic.${sort}`, order)
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

  findOneByTitle(title: string) {
    return this.topicRepository.findOneBy({title});
  }
}