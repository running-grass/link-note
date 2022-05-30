import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Auth } from 'src/entity/auth.entity';
import { User } from 'src/entity/user.entity';
import { Repository } from 'typeorm';
import { UserService } from '../user/user.service';
import { JwtService } from '@nestjs/jwt'
import { JwtUser } from '../../util/type';
import { guid } from 'link-note-common';

@Injectable()
export class AuthService {

  constructor(
    @InjectRepository(Auth)
    private authRepository: Repository<Auth>,
    private userService: UserService,
    private jwtService: JwtService

  ) { }

  async updatePassword(user: User, password: string) {
    // 判断有没有存储密码
    let auth = await this.authRepository.findOne({
      where: { user: {id: user.id}}, 
      select: {
        id: true,
        password: true,
      }})

    if (!auth) {
      auth = new Auth()
      auth.id = guid()
      auth.user = user
    } else {
      // 判断是否更改了密码

      if (auth.password === password) {
        throw new Error("密码不能和旧密码相同")
      }
    }

    auth.user = user
    auth.password = password;

    return this.authRepository.save(auth);
  }

  async validateUser(username: string, pass: string) {
    const user = await this.userService.findByUsername(username);

    if (!user) {
      throw new NotFoundException('未找到用户');
    }
    const auth = await this.getPassword(user);

    if (auth.password === pass) {
      return user;
    } else {
      throw new Error('密码不对');
    }

  }

  async getPassword(user: User): Promise<Auth | null> {
    return this.authRepository.findOne({
      where: {
        user: {
          id: user.id
        }
      }
    })
  }

  async login(user: User) {
    const payload: JwtUser = { username: user.username, uid: user.id };
    return {
      access_token: this.jwtService.sign(payload),
    };
  }

}