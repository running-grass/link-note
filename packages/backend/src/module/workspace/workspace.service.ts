import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from 'src/entity/user.entity';
import { Workspace } from 'src/entity/workspace.entity';
import { Repository } from 'typeorm';

@Injectable()
export class WorkspaceService {

  constructor(
    @InjectRepository(Workspace)
    private workspaceRepository: Repository<Workspace>
  ) { }

  createWorkspace(user: User, name: string, displayName: string) {
    const ws = new Workspace()
    ws.owner = user
    ws.name = name
    ws.displayName = displayName

    return this.workspaceRepository.save(ws)
  }

  getAllByUserId(uid: number) {
    return this.workspaceRepository
      .createQueryBuilder('ws')
      .where(`ws.ownerId=${uid}`)
      .getMany()
  }
}
