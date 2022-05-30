import { UnauthorizedException } from "@nestjs/common";
import { Query } from "@nestjs/graphql";
import { User } from "src/entity/user.entity";
import { CurrentUser } from "src/util/decorater";
import { UserService } from "../user/user.service";
import { JwtUser } from "../../util/type";


export abstract class AuthedResolver {

  constructor(
    @CurrentUser() private currentUser: JwtUser,
    private userService: UserService,
  ) { }


  protected getCurrentUser(){
    if (this.currentUser?.uid) {
      return this.userService.findById(this.currentUser?.uid)
    } else {
      throw new UnauthorizedException('当前未登录')
    }
  }
}