import { ChildEntity, Column, Index } from "typeorm";
import { Node } from "./node.entity";

@ChildEntity()
@Index(["workspace", "title"], { unique: true })
export class Topic extends Node{
    @Column()
    title: string;

    @Column()
    @Index()
    isTag: boolean
}