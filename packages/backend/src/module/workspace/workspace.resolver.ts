import { Resolver } from '@nestjs/graphql';
import { WorkspaceDto } from 'src/graphql/model';

@Resolver(of => WorkspaceDto)
export class WorkspaceResolver {}
