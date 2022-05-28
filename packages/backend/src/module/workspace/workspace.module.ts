import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Workspace } from 'src/entity/workspace.entity';
import { WorkspaceResolver } from './workspace.resolver';
import { WorkspaceService } from './workspace.service';

@Module({
  imports: [TypeOrmModule.forFeature([Workspace])],
  providers: [WorkspaceResolver, WorkspaceService],
  exports: [WorkspaceService]
})
export class WorkspaceModule {}
