import { Field, InputType, Int } from '@nestjs/graphql';
import { CardType } from 'src/enum/common';
import { GUIDScalar } from 'src/graphql.scalar';
import { Guid } from 'src/util/type';

@InputType()
export class CardCreateInput {
    @Field(() => GUIDScalar, { nullable: false})
    belongId: Guid

    @Field(() => GUIDScalar, { nullable: true})
    parentId?: Guid

    @Field(() => GUIDScalar, { nullable: true})
    leftId?: Guid

    @Field({ nullable: true})
    content?: string

    @Field(type => CardType, { nullable: true})
    cardType?: CardType
}

@InputType()
export class CardInputDto {
    @Field(() => GUIDScalar)
    id: Guid;

    @Field()
    content: string;

    @Field(() => CardType)
    cardType: CardType;

    @Field(() => [CardInputDto])
    childrens: [CardInputDto];
}