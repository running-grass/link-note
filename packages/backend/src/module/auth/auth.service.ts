import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Auth } from 'src/entity/auth.entity';
import { User } from 'src/entity/user.entity';
import { EntityManager, Repository, TreeRepository } from 'typeorm';

@Injectable()
export class AuthService {

  constructor(
    @InjectRepository(Auth)
    private authRepository: Repository<Auth>
  ) {}

  updatePassword(user: User, password: string) {
    return this.authRepository.save(this.authRepository.create({
      user,
      password,
    }));
  }
  
}