import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from 'src/entity/user.entity';
import { guid } from 'src/util/common';
import { Guid } from 'src/util/type';
import { Repository } from 'typeorm';
import { WorkspaceService } from '../workspace/workspace.service';

@Injectable()
export class UserService {

  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private workspaceService: WorkspaceService,
  ) { }

  async createUser(username: string, email?: string, phone?: string) {
    const user = this.userRepository.create({
      id: guid(),
      username,
      phone,
      email,
    });


    const savedUser = await this.userRepository.save(user);

    await this.workspaceService.createWorkspace(savedUser, username, username + '的工作空间');

    return savedUser
  }

  async findById(id: Guid){
    return this.userRepository.findOne({ where: { id }});
  }

  async findByUsername(username: string){
    return this.userRepository.findOne({ where: { username }});
  }

}