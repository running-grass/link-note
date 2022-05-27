import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TopicModule } from './module/topic/topic.module';
import { CardModule } from './module/card/card.module';

import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { ApolloServerPluginLandingPageLocalDefault } from 'apollo-server-core';
import  { join } from 'path';
import { ServeStaticModule } from '@nestjs/serve-static';
import { ConfigModule } from '@nestjs/config';

import { configuration } from './configuration'
import { UserModule } from './module/user/user.module';
import { AuthModule } from './module/auth/auth.module';
import { WorkspaceModule } from './module/workspace/workspace.module';

const otherConfig = {
  synchronize: true, // TODO 0.1版本的时候关掉
  // logging: process.env.NODE_ENV === 'development',
  migrations: [],
  subscribers: [],
  autoLoadEntities: true,
}

let ormConfig
switch (process.env.DB_TYPE) {
  case 'sqlite':
    ormConfig = {
      type: 'sqlite',
      database: process.env.DB_SQLITE_DATABASE,
    }
    break
  case 'mysql':
    ormConfig = {
      type: 'mysql',
      url: process.env.DB_MYSQL_URL
    }
    break
  default:
    throw new Error('您配置的DB_TYPE有误')
}
@Module({
  imports: [
    TypeOrmModule.forRoot({
      ...ormConfig,
      ...otherConfig,
    }),
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      debug: true,
      path: '/api/graphql',
      playground: false,
      plugins: [ApolloServerPluginLandingPageLocalDefault()],
      autoSchemaFile: join(__dirname, 'generated/schema.gql'),
    }),
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', 'frontend-root'),
    }),
    ConfigModule.forRoot({
      load: [configuration],
      isGlobal: true
    }),
    TopicModule,
    CardModule,
    UserModule,
    AuthModule,
    WorkspaceModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {
}
