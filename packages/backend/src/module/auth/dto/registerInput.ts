import { Field, InputType, Int } from '@nestjs/graphql';
import { CardType } from 'src/enum/common';

@InputType()
export class RegisterInput {
    @Field({ nullable: false})
    username!: string

    @Field({ nullable: true})
    email?: string

    @Field({ nullable: true})
    phone?: string

    @Field({ nullable: false})
    password: string
}
