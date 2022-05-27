import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from 'src/entity/user.entity';
import { WorkspaceModule } from '../workspace/workspace.module';
import { UserResolver } from './user.resolver';
import { UserService } from './user.service';

@Module({
  imports: [TypeOrmModule.forFeature([User]), WorkspaceModule],
  providers: [UserService, UserResolver],
  exports: [UserService]
})
export class UserModule {}