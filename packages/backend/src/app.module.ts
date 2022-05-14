import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TopicModule } from './topic/topic.module';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { join } from 'path';
import { ApolloServerPluginLandingPageLocalDefault } from 'apollo-server-core';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: './link-note.db',

      synchronize: true,
      logging: true,
      migrations: [],
      subscribers: [],
      entities: ["dist/entity/*.js"]
    }),
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      typePaths: ['./**/*.graphql'],
      definitions: {
        path: join(process.cwd(), 'src/graphql.ts'),
        outputAs: 'class',
        // watch: true
      },

      playground: false,
      plugins: [ApolloServerPluginLandingPageLocalDefault()],
      
    }),
    TopicModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {
}
