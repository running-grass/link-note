import { ChildEntity, Column, Index } from "typeorm";
import { Node } from "./node.entity";

@ChildEntity()
export class Topic extends Node{
    @Column()
    @Index({ unique: true })
    title: string;
}