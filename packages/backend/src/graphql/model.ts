import { Field, Int, ObjectType } from "@nestjs/graphql";

export enum NodeDtoSort {
    createDate = "createDate",
    updateDate = "updateDate"
}

export enum Order {
    DESC = "DESC",
    ASC = "ASC"
}

@ObjectType({ description: '主题的DTO' })
export class TopicDto {
    @Field(() => Int)
    id: number;

    @Field()
    title: string;
}

@ObjectType({description: "各个节点的公共字段"})
export abstract class NodeDto {
    @Field(() => Int)
    id: number;

    @Field()
    createDate: Date;

    @Field()
    updateDate: Date;
}
