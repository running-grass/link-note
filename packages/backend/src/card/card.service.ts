import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Connection, DataSource, EntityManager, TreeRepository } from 'typeorm';
import { Topic } from '../entity/topic.entity';
import { Card } from '../entity/card.entity';
import { Node } from '../entity/node.entity'

import { BaseSort, CardType } from '../enum/common'
@Injectable()
export class CardService {
  private cardRepository: TreeRepository<Card>
  
  constructor(
    private manager: EntityManager,
  ) { 
    this.cardRepository = manager.getTreeRepository(Card);
  }

  async createOne(belong: Topic, parent: Card, content: string = "", cardType: CardType = CardType.INLINE) {
    const card = new Card();
    card.belong = belong;
    card.parent = parent;
    card.content = content;
    card.cardType = cardType;

    return await this.cardRepository.save(card);
  }


  async findOneById(id: number) {
    return await this.cardRepository.findOneBy({ id });
  }


  async getCardTree(topic: Topic) {
    // 获取根节点
    const roots = await this.cardRepository.createQueryBuilder('card')
                                              .where(`card.belongId = ${topic.id}`)
                                              .andWhere(`card.parentId IS NULL`)
                                              .getMany();
    

    const cards = await Promise.all(roots.map(root =>  this.cardRepository.findDescendantsTree(root)));

    return cards;
  }

}