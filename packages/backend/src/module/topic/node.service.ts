import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Node } from '../../entity/node.entity';

@Injectable()
export class NodeService {

  constructor(
    @InjectRepository(Node)
    private nodeRepository: Repository<Node>,
  ) {}

  findOneById(id: number) {
    return this.nodeRepository.findOneBy({id: id});
  }

}