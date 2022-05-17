import { Args, Int, Mutation, Parent, Query, ResolveField, Resolver } from "@nestjs/graphql";
import { Card } from "src/entity/card.entity";
import { CardType } from "src/enum/common";
import { TopicDto, CardDto } from "src/graphql/model";
import { NodeService } from "src/topic/node.service";
import { TopicService } from "src/topic/topic.service";
import { CardService } from "./card.service";
import { CardCreateInput } from "./dto/cardCreateInput";

@Resolver(of => CardDto)
export class CardResolver {
  constructor(
    private cardService: CardService,
    private nodeService: NodeService,
    private topicService: TopicService,
  ) {}

  @Mutation(returns => CardDto)
  async createNewCard(@Args('cardCreateInput') cardCreateInput: CardCreateInput) {
    const node = await this.topicService.findOneById(cardCreateInput.belongId);

    if (!node) {
      throw new Error("所属节点不存在");
    }

    let parent;
    if (cardCreateInput.parentId) {
      parent = await this.cardService.findOneById(cardCreateInput.parentId);
    }

    return await this.cardService.createOne(node, parent, cardCreateInput.content, cardCreateInput.cardType);
  }

  @ResolveField(returns => [CardDto!]!)
  childrens(@Parent() parent: CardDto) {
    return parent.childrens ?? []
  }
}