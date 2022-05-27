import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';
import { User } from 'src/entity/user.entity';
import { JwtUser } from 'src/module/auth/dto/jwtUser';

export const CurrentUser = createParamDecorator<any, any, JwtUser>(
  (data: unknown, context: ExecutionContext) => {
    const ctx = GqlExecutionContext.create(context);
    return ctx.getContext().req.user as JwtUser;
  },
);