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
import { ServeStaticModule } from '@nestjs/serve-static';

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
    }),
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      debug: true,
      path: '/api/graphql',
      playground: false,
      
      plugins: [ApolloServerPluginLandingPageLocalDefault()],
      
      autoSchemaFile: join(process.cwd(), 'generated/schema.gql'),
    }),
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, 'frontend-root'),
    }),
    TopicModule,
    CardModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {
}
