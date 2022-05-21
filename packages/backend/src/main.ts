import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import "reflect-metadata";
import './graphql/registerEnum';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(4000);
}

bootstrap();
