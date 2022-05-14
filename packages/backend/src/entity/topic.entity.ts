import { ChildEntity, Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";
import { Node } from "./node.entity";

@ChildEntity()
export class Topic extends Node{
    @Column()
    @Index({ unique: true })
    title: string;
}