import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Auth } from 'src/entity/auth.entity';
import { EntityManager, Repository, TreeRepository } from 'typeorm';

@Injectable()
export class AuthService {

  constructor(
    @InjectRepository(Auth)
    private topicRepository: Repository<Auth>
  ) {}
  
}