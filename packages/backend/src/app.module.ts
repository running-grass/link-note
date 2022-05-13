import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TopicModule } from './topic/topic.module';

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
    TopicModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {
}
