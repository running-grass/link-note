import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Auth } from 'src/entity/auth.entity';
import { UserModule } from '../user/user.module';

@Module({
  imports: [TypeOrmModule.forFeature([Auth]), UserModule],
  providers: [],
  controllers: [],
  exports: []
})
export class AuthModule {}