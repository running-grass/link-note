import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Guid } from 'src/util/type';
import { Repository } from 'typeorm';
import { Node } from '../../entity/node.entity';

@Injectable()
export class NodeService {

  constructor(
    @InjectRepository(Node)
    private nodeRepository: Repository<Node>,
  ) {}

  findOneById(id: Guid) {
    return this.nodeRepository.findOneBy({id: id});
  }

}