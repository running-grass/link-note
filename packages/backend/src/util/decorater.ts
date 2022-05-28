import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';
import { JwtUser } from 'src/module/auth/dto/jwtUser';

export const CurrentUser = createParamDecorator<any, any, JwtUser>(
  (data: unknown, context: ExecutionContext) => {
    const ctx = GqlExecutionContext.create(context);
    return ctx.getContext().req.user as JwtUser;
  },
);


export const CurrentWorkspaceId = createParamDecorator<any, any, number>(
  (data: unknown, context: ExecutionContext) => {
    const ctx = GqlExecutionContext.create(context);
    return Number(ctx.getContext().req.headers['workspace-id'])
  },
);