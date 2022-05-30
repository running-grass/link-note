import { Injectable } from '@nestjs/common';
import { EntityManager, TreeRepository } from 'typeorm';
import { Topic } from '../../entity/topic.entity';
import { Card } from '../../entity/card.entity';

import { flatten } from 'ramda'
// import assert from 'node:assert';

import { CardType } from '../../enum/common'
import { Guid } from 'src/util/type';
import { guid } from 'src/util/common';
@Injectable()
export class CardService {
  private cardRepository: TreeRepository<Card>

  constructor(
    manager: EntityManager,
  ) {
    this.cardRepository = manager.getTreeRepository(Card);
  }

  async createOne(belong: Topic, parent: Card, content: string = "", cardType: CardType = CardType.INLINE, leftId?: Guid) {
    const card = new Card();
    card.id = guid()
    card.belong = belong;
    card.parent = parent;
    card.content = content;
    card.cardType = cardType;
    card.leftId = leftId;
    card.workspace = belong.workspace

    return  await this.cardRepository.save(card);
  }


  async findOneById(id: Guid) {
    return await this.cardRepository.findOneBy({ id });
  }

  // 根据leftid对数组进行排序
  sortCardsTreeByLeftId(cards: Card[]): Card[] {
    if (!cards?.length) return []

    const old = cards.map(card => ({
      ...card,
      childrens: this.sortCardsTreeByLeftId(card.childrens),
    }))

    let arr = []

    // 下一个需要被移入新数组的
    let next = old.findIndex(card => !card.leftId)

    if (next === -1) {
      // console.error('找不到第一个节点')
      // next = 0
      throw new Error('找不到第一个节点')
    }

    do {
      const prevId = old[next].id;
      // 复制到新数组
      arr.push(old[next])
      // 从旧数组删掉
      old.splice(next, 1)

      next = old.findIndex(card => card.leftId === prevId)
    } while (next !== -1)

    if (old.length) {
      console.warn(`剩余${old.length}个card未排序`)
      arr = arr.concat(old);
    }


    return arr;
  }

  async getCardTree(topic: Topic) {
    // 获取根节点
    const roots = await this.cardRepository.createQueryBuilder()
      .where({
        belong: {
          id: topic.id
        }
      })
      .andWhere(`parentId IS NULL`)
      .getMany()
    
    const cards = await Promise.all(
      roots.map(root => this.cardRepository.findDescendantsTree(root))
    )
    // .then(xss => { 
    //   return flatten(xss)
    // });

    return this.sortCardsTreeByLeftId(cards);
  }

  async saveCards(cards: Card[]) {
    return this.cardRepository.save(cards)
  }

  async deleCard(cardId: Guid) {
    return this.cardRepository.softDelete(cardId)
  }

}