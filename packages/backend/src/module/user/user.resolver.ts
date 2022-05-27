import { UseGuards } from "@nestjs/common";
import { Parent, Query, ResolveField, Resolver } from "@nestjs/graphql";
import { UserDto, WorkspaceDto } from "src/graphql/model";
import { CurrentUser } from "src/util/decorater";
import { JwtUser } from "../auth/dto/jwtUser";
import { GqlAuthGuard } from "../auth/gql.guard";
import { WorkspaceService } from "../workspace/workspace.service";
import { UserService } from "./user.service";

@UseGuards(GqlAuthGuard)
@Resolver(of => UserDto)
export class UserResolver {
  constructor(
    private userService: UserService,
    private workspaceService: WorkspaceService,
  ) {}

  @ResolveField(() => [WorkspaceDto])
  workspaces(@Parent() user: UserDto) {
    if (user.workspaces) {
      return user.workspaces
    }
    return this.workspaceService.getAllByUserId(user.id);
  }

  @Query(returns => UserDto)
  currentUser(@CurrentUser() curr: JwtUser) {
    return this.userService.findById(curr.uid);
  }
}