import { UseGuards } from "@nestjs/common";
import { Args, Int, Mutation, Parent, ResolveField, Resolver } from "@nestjs/graphql";
import { Card } from "src/entity/card.entity";
import { GUIDScalar } from "src/graphql.scalar";
import { CardDto } from "src/graphql/model";
import { NodeService } from "src/module/topic/node.service";
import { TopicService } from "src/module/topic/topic.service";
import { CurrentWorkspaceId } from "src/util/decorater";
import { Guid } from "src/util/type";
import { GqlAuthGuard } from "../auth/gql.guard";
import { CardService } from "./card.service";
import { CardCreateInput, CardInputDto } from "./dto/cardCreateInput";

@UseGuards(GqlAuthGuard)
@Resolver(of => CardDto)
export class CardResolver {
  constructor(
    private cardService: CardService,
    private topicService: TopicService,
  ) { }


  @ResolveField(returns => [CardDto!]!)
  childrens(@Parent() parent: CardDto) {
    return parent.childrens ?? []
  }


  @Mutation(returns => CardDto)
  async createNewCard(@Args('cardCreateInput') cardCreateInput: CardCreateInput,
    @CurrentWorkspaceId() wid: Guid) {
    const node = await this.topicService.findOneById(wid, cardCreateInput.belongId);

    if (!node) {
      throw new Error("所属节点不存在");
    }

    let parent;
    if (cardCreateInput.parentId) {
      parent = await this.cardService.findOneById(cardCreateInput.parentId);
    }

    return await this.cardService.createOne(
      node,
      parent,
      cardCreateInput.content,
      cardCreateInput.cardType,
      cardCreateInput.leftId);
  }

  private dtoTreeToEntityTree(cards: CardInputDto[], parent?: Card): Card[] {
    if (!cards.length) return []

    let prevId: Guid = null

    let arr: Card[] = []
    for (const card of cards) {
      const curr = new Card();
      curr.id = card.id
      curr.cardType = card.cardType
      curr.content = card.content
      curr.leftId = prevId
      curr.parent = parent
      arr.push(curr)

      prevId = curr.id

      if (card.childrens.length) {
        arr = arr.concat(this.dtoTreeToEntityTree(card.childrens, curr))
      }
    }

    return arr
  }

  @Mutation(returns => Int, {
    description: "传入一个有序的CardDTO树，更新数据库中的leftId和parentId"
  })
  async updateCards(@Args('cards', { type: () => [CardInputDto] }) cards: [CardInputDto]) {
    const cardEntityTree = this.dtoTreeToEntityTree(cards)

    await this.cardService.saveCards(cardEntityTree);

    return cards.length;
  }

  @Mutation(returns => Int, {
    description: '删除指定的card'
  })
  async deleteCard(@Args('cardId', { type: () => GUIDScalar }) cardId: Guid) {
    await this.cardService.deleCard(cardId)
    return 1
  }
}