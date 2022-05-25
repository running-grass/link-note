import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Auth } from 'src/entity/auth.entity';
import { UserModule } from '../user/user.module';
import { AuthResolver } from './auth.resolver';
import { AuthService } from './auth.service';
import { LocalStrategy } from './local.strategy';

@Module({
  imports: [TypeOrmModule.forFeature([Auth]), UserModule, PassportModule],
  providers: [AuthService, AuthResolver, LocalStrategy],
  exports: [UserModule, AuthService]
})
export class AuthModule {}