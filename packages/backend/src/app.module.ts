import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TopicModule } from './topic/topic.module';
import { CardModule } from './card/card.module';

import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { ApolloServerPluginLandingPageLocalDefault } from 'apollo-server-core';
import  { join } from 'path';


@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: './link-note.db',

      synchronize: true,
      logging: true,
      migrations: [],
      subscribers: [],
      autoLoadEntities: true,

      // entities: ["./**/entity/*.js"]
    }),
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      debug: true,
      // typePaths: ['./**/*.graphql'],
      playground: false,
      plugins: [ApolloServerPluginLandingPageLocalDefault()],
      
      autoSchemaFile: join(process.cwd(), 'generated/schema.gql'),
    }),
    TopicModule,
    CardModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {
}
