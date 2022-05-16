import { Args, Int, Mutation, Parent, Query, ResolveField, Resolver } from "@nestjs/graphql";
import { NodeDtoSort, Order, TopicDto } from "src/graphql/model";
import { Topic } from "../entity/topic.entity";
import { TopicsArgs } from "./dto/topicsArgs";
// import { NodeDtoSort, Order } from "../graphql";
import { TopicService } from "./topic.service";

@Resolver(of => TopicDto)
export class TopicResolver {
  constructor(
    private topicService: TopicService,
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
    return this.topicService.findAll(args.sort, args.order, args.limit, args.search);
  }
  
  // @ResolveField()
  // async parent(@Parent() topic: Topic) {
  //   return this.topicService.findAll();
  // }

  @Mutation(returns => TopicDto)
  async createTopic(@Args('title') title: string) {
    return this.topicService.newOne(title);
  }
}