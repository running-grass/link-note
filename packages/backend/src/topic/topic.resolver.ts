import { Args, Mutation, Parent, Query, ResolveField, Resolver } from "@nestjs/graphql";
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

  @Query(returns => TopicDto)
  async topic(@Args('id') id: number) {
    return this.topicService.findOneById(id);
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