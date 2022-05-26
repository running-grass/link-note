import { UseGuards } from "@nestjs/common";
import { Args, Mutation, Resolver } from "@nestjs/graphql";
import { AuthGuard } from "@nestjs/passport";
import { User } from "src/entity/user.entity";
import { UserDto } from "src/graphql/model";
import { UserService } from "../user/user.service";
import { AuthService } from "./auth.service";
import { RegisterInput } from "./dto/registerInput";

@Resolver()
export class AuthResolver {
  constructor(
    private authService: AuthService,
    private userService: UserService,
  ) { }

  @Mutation(returns => UserDto)
  async registerUser(@Args("registerData") registerData: RegisterInput) {
    const user = await this.userService.createUser(registerData.username, registerData.email, registerData.phone);

    const auth = this.authService.updatePassword(user, registerData.password)

    return user;
  }

  // // @UseGuards(GqlAuthGuard)
  // @UseGuards(AuthGuard('local'))
  // @Mutation(returns => UserDto)
  // async login(@Args('username') username: string, @Args('password') password: string) {
  //   const user = new User()
  //   return user
  // }
  
}