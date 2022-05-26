import { UseGuards } from "@nestjs/common";
import { Resolver } from "@nestjs/graphql";
import { UserDto } from "src/graphql/model";
import { GqlAuthGuard } from "../auth/gql.guard";

@UseGuards(GqlAuthGuard)


@Resolver(of => UserDto)
export class UserResolver {
  constructor(
  ) {}
}