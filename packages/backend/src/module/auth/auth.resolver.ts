import { Args, Mutation, Resolver } from "@nestjs/graphql";
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
}