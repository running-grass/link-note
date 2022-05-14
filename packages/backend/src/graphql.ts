
/*
 * -------------------------------------------------------
 * THIS FILE WAS AUTOMATICALLY GENERATED (DO NOT MODIFY)
 * -------------------------------------------------------
 */

/* tslint:disable */
/* eslint-disable */
export enum NodeDtoSort {
    createDate = "createDate",
    updateDate = "updateDate"
}

export enum Order {
    DESC = "DESC",
    ASC = "ASC"
}

export class TopicDto {
    id: number;
    title: string;
    parent?: Nullable<Nullable<NodeDto>[]>;
}

export class NodeDto {
    id: number;
    createDate: string;
    updateDate: string;
}

export abstract class IQuery {
    abstract topic(id: number): Nullable<TopicDto> | Promise<Nullable<TopicDto>>;

    abstract topics(sort?: Nullable<NodeDtoSort>, order?: Nullable<Order>, limit?: Nullable<number>): Nullable<Nullable<TopicDto>[]> | Promise<Nullable<Nullable<TopicDto>[]>>;
}

type Nullable<T> = T | null;
