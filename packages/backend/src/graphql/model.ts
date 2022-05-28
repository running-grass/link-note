import { Field, Int, ObjectType } from "@nestjs/graphql";
import { CardType } from "src/enum/common";


@ObjectType({description: "笔记卡片"})
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



@ObjectType({ description: "各个节点的公共字段" })
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
export class TopicDto extends NodeDto {
    @Field()
    title: string;
}

@ObjectType({ description: "用户的工作空间" })
export class WorkspaceDto {
    @Field(() => Int)
    id: number

    @Field({ description: "全局不重复的key" })
    name: string

    @Field({ description: "显示用名称" })
    displayName: string
}

@ObjectType({ description: "用户信息" })
export class UserDto {
    @Field()
    id: number

    @Field({ description: "用户的用户名，不可修改" })
    username: string

    @Field({ nullable: true, description: "用户的电子邮箱" })
    email?: string

    @Field({ nullable: true, description: "用户的手机号，不带国际区号" })
    phone?: string

    @Field(() => [WorkspaceDto], { description: "用户的工作空间列表" })
    workspaces: WorkspaceDto[]
}