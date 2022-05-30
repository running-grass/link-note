import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';
import { Guid, JwtUser } from './type';

export const CurrentUser = createParamDecorator<any, any, JwtUser>(
  (data: unknown, context: ExecutionContext) => {
    const ctx = GqlExecutionContext.create(context);
    return ctx.getContext().req.user as JwtUser;
  },
);

export const CurrentWorkspaceId = createParamDecorator<any, any, Guid>(
  (data: unknown, context: ExecutionContext) => {
    const ctx = GqlExecutionContext.create(context);
    return String(ctx.getContext().req.headers['workspace-id'])
  },
);