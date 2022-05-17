import { ArgsType, Field, InputType, Int } from '@nestjs/graphql';
import { BaseSort, CardType, Order } from 'src/enum/common';

@InputType()
export class CardCreateInput {
    @Field(type => Int, { nullable: false})
    belongId: number

    @Field(type => Int, { nullable: true})
    parentId: number

    @Field({ nullable: true})
    content: string

    @Field(type => CardType, { nullable: true})
    cardType: CardType
}