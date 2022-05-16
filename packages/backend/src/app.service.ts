import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  // constructor(private readonly appService: ) {}

  getHello(): string {
    return 'Hello World!';
  }
}
