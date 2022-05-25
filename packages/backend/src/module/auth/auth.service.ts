import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Auth } from 'src/entity/auth.entity';
import { User } from 'src/entity/user.entity';
import { EntityManager, Repository, TreeRepository } from 'typeorm';
import { UserService } from '../user/user.service';

@Injectable()
export class AuthService {

  constructor(
    @InjectRepository(Auth)
    private authRepository: Repository<Auth>,
    private userService: UserService,
  ) {}

  updatePassword(user: User, password: string) {
    return this.authRepository.save(this.authRepository.create({
      user,
      password,
    }));
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

  async getPassword(user: User) {
    return this.authRepository.createQueryBuilder('auth').where('uid='+ user.id).getOne();
  }
  
}