import { Field, Int, ObjectType } from "@nestjs/graphql";
import { CardType } from "src/enum/common";


@ObjectType()
export class CardDto {
    @Field(() => Int)
    id: number;

    @Field()
    createAt: Date;

    @Field()
    updateAt: Date;

    @Field()
    content: string;

    @Field(() => Int, { nullable: true })
    leftId?: number

    @Field(() => CardType)
    cardType: CardType;

    @Field(() => [CardDto])
    childrens: [CardDto];
}



@ObjectType({description: "各个节点的公共字段"})
export abstract class NodeDto {
    @Field(() => Int)
    id: number;

    @Field()
    createAt: Date;

    @Field()
    updateAt: Date;

    @Field(() => [CardDto])
    cards!: [CardDto]
}

@ObjectType({ description: '主题的DTO' })
export class TopicDto extends NodeDto{
    @Field()
    title: string;
}
