import { Args, Parent, Query, ResolveField, Resolver } from "@nestjs/graphql";
import { Topic } from "../entity/topic.entity";
import { TopicService } from "./topic.service";

@Resolver('Topic')
export class TopicResolver {
  constructor(
    private topicService: TopicService,
  ) {}

  @Query('topic')
  async topic(@Args('id') id: number) {
    return this.topicService.findOneById(id);
  }
  
  @ResolveField()
  async parent(@Parent() topic: Topic) {
    return this.topicService.findAll();
  }
}