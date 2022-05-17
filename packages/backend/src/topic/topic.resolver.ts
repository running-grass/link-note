import { Args, Int, Mutation, Parent, Query, ResolveField, Resolver } from "@nestjs/graphql";
import { CardService } from "src/card/card.service";
import { Topic } from "src/entity/topic.entity";
import { CardDto, TopicDto } from "src/graphql/model";
import { TopicsArgs } from "./dto/topicsArgs";
import { TopicService } from "./topic.service";

@Resolver(of => TopicDto)
export class TopicResolver {
  constructor(
    private topicService: TopicService,
    private cardService: CardService,
  ) {}

  @Query(returns => TopicDto, { nullable: true})
  async topic(@Args('id', { type: () => Int, nullable: true}) id: number
            , @Args('title', { nullable: true}) title: string ) {
    if (id) {
      return this.topicService.findOneById(id);
    } else if (title) {
      return this.topicService.findOneByTitle(title);
    } else {
      throw new Error('id 和 title 必须传一个');
    }
  }
  
  @Query(returns => [TopicDto!]!, {
    description: "查询主题列表"
  })
  async topics(@Args() args: TopicsArgs) {      
    return await this.topicService.findAll(args.sort, args.order, args.limit, args.search);
  }
  
  @ResolveField(returns => [CardDto!]!)
  async cards(@Parent() topic: Topic) {
    return await this.cardService.getCardTree(topic);
  }

  @Mutation(returns => TopicDto)
  async createTopic(@Args('title') title: string) {
    return await this.topicService.newOne(title);
  }
}