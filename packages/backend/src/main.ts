import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import "reflect-metadata";
import { DataSource } from "typeorm";
import { Topic } from './entity/topic.entity'

// const AppDataSource = new DataSource({
//   type: 'sqlite',
//   database: './link-note.db',

//   synchronize: true,
//   logging: true,
//   migrations: [],
//   subscribers: [],
//   entities: ["dist/entity/*.js"]
// });

// AppDataSource.initialize().then(async () => {
//   const topicRep = AppDataSource.getRepository(Topic)
//   const topic = new Topic();
//   topic.title = "test1";
//   await topicRep.save(topic);
//   const l = await topicRep.find();
//   console.log(l);
  
// })



async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(4000);
}
bootstrap();
