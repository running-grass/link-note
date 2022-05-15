import { Args, Mutation, Parent, Query, ResolveField, Resolver } from "@nestjs/graphql";
import { Topic } from "../entity/topic.entity";
import { NodeDtoSort, Order } from "../graphql";
import { TopicService } from "./topic.service";

@Resolver('TopicDto')
export class TopicResolver {
  constructor(
    private topicService: TopicService,
  ) {}

  @Query('topic')
  async topic(@Args('id') id: number) {
    return this.topicService.findOneById(id);
  }
  
  @Query()
  async topics(  @Args('sort') sort: NodeDtoSort = NodeDtoSort.createDate,
                 @Args('order') order: Order = Order.DESC, 
                 @Args('limit') limit: number = 20) {      
    return this.topicService.findAll(sort, order, limit);
  }
  
  @ResolveField()
  async parent(@Parent() topic: Topic) {
    return this.topicService.findAll();
  }

  @Mutation()
  async createTopic(@Args('title') title: string) {
    return this.topicService.newOne(title);
  }
}