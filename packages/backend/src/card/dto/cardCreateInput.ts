import { ArgsType, Field, InputType, Int } from '@nestjs/graphql';
import { BaseSort, CardType, Order } from 'src/enum/common';
import { CardDto } from 'src/graphql/model';

@InputType()
export class CardCreateInput {
    @Field(type => Int, { nullable: false})
    belongId: number

    @Field(type => Int, { nullable: true})
    parentId?: number

    @Field(type => Int, { nullable: true})
    leftId?: number

    @Field({ nullable: true})
    content?: string

    @Field(type => CardType, { nullable: true})
    cardType?: CardType
}

@InputType()
export class CardInputDto {
    @Field(() => Int)
    id: number;

    @Field()
    content: string;

    @Field(() => CardType)
    cardType: CardType;

    @Field(() => [CardInputDto])
    childrens: [CardInputDto];
}