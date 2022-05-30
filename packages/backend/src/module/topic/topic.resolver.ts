import { Args, Int, Mutation, Parent, Query, ResolveField, Resolver } from "@nestjs/graphql";
import { CardService } from "src/module/card/card.service";
import { Topic } from "src/entity/topic.entity";
import { CardDto, TopicDto } from "src/graphql/model";
import { TopicsArgs } from "./dto/topicsArgs";
import { TopicService } from "./topic.service";
import { UseGuards } from "@nestjs/common";
import { GqlAuthGuard } from "../auth/gql.guard";
import { CurrentWorkspaceId } from "src/util/decorater";
import { Guid } from "src/util/type";
import { GUIDScalar } from "src/graphql.scalar";

@Resolver(of => TopicDto)
@UseGuards(GqlAuthGuard)
export class TopicResolver {
  constructor(
    private topicService: TopicService,
    private cardService: CardService,
  ) { }


  @ResolveField(returns => [CardDto!]!)
  async cards(@Parent() topic: Topic) {
    return await this.cardService.getCardTree(topic);
  }

  @Query(returns => TopicDto, { nullable: true })
  async topic(
    @Args('id', { nullable: true , type: () => GUIDScalar}) id: Guid,
    @Args('title', { nullable: true }) title: string,
    @CurrentWorkspaceId() wid: Guid
  ) {
    if (id) {
      return this.topicService.findOneById(wid, id);
    } else if (title) {
      return this.topicService.findOneByTitle(wid, title);
    } else {
      throw new Error('id 和 title 必须传一个');
    }
  }

  @Query(returns => [TopicDto!]!, {
    description: "查询主题列表"
  })
  async topics(
    @Args() args: TopicsArgs,
    @CurrentWorkspaceId() wid: Guid
  ) {
    return await this.topicService.findAll(wid, args.sort, args.order, args.limit, args.search);
  }


  @Mutation(returns => TopicDto,)
  async createTopic(
    @Args('title') title: string,
    @CurrentWorkspaceId() wid: Guid
  ) {
    return await this.topicService.newOne(wid, title);
  }
}