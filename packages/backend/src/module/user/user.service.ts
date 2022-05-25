import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from 'src/entity/user.entity';
import { Repository } from 'typeorm';

@Injectable()
export class UserService {

  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>
  ) { }

  async createUser(username: string, email?: string, phone?: string) {
    const user = this.userRepository.create({
      username,
      phone,
      email,
    });

    return await this.userRepository.save(user)
  }

}