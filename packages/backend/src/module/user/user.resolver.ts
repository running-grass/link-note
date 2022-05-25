import { Resolver } from "@nestjs/graphql";
import { UserDto } from "src/graphql/model";


@Resolver(of => UserDto)
export class UserResolver {
  constructor(
  ) {}
}