import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Workspace } from 'src/entity/workspace.entity';
import { guid } from 'src/util/common';
import { Guid } from 'src/util/type';
import { Repository } from 'typeorm';
import { Topic } from '../../entity/topic.entity';
import { BaseSort, Order } from '../../enum/common'

@Injectable()
export class TopicService {

  constructor(
    @InjectRepository(Topic)
    private topicRepository: Repository<Topic>
  ) { }

  findAll(wid: Guid
    , sort: BaseSort = BaseSort.id
    , order: Order = Order.DESC
    , limit: number = 10
    , search: string): Promise<Topic[]> {

    let build = this.topicRepository.createQueryBuilder('topic')
    .where(`topic.wid = "${wid}"`)

    // 字符串匹配
    if (search) {
      build = build.andWhere("topic.title like :keyword", { keyword: `%${search}%` });
    }

    return build.orderBy(`topic.${sort}`, order)
      .limit(limit)
      .getMany();
  }

  newOne(wid: Guid, title: string): Promise<Topic> {
    const ws = new Workspace()
    ws.id = wid

    const t = new Topic();
    t.id = guid()
    t.title = title

    t.workspace = ws

    return this.topicRepository.save(t);
  }

  findOneById(wid: Guid, id: Guid) {
    return this.topicRepository.findOne({
      where: {
        id,
        workspace: {
          id: wid
        }
      },
      
      relations: {
        workspace: true,
      },
    })
  }

  findOneByTitle(wid: Guid, title: string) {
    return this.topicRepository.findOne({
      where: {
        title,
        workspace: {
          id: wid
        }
      },
      relations: {
        workspace: true,
      },
    })
  }
}