import { Column, CreateDateColumn, DeleteDateColumn, Entity, Index, JoinTable, ManyToMany, PrimaryGeneratedColumn, TableInheritance, UpdateDateColumn, VersionColumn } from "typeorm";
import { Topic } from "./topic.entity";

@Entity()
@TableInheritance({ column: { type: "varchar", name: "type" } })
export class Node {
    @PrimaryGeneratedColumn()
    id: number;

    @CreateDateColumn()
    @Index()
    createDate: Date;

    @UpdateDateColumn()
    @Index()
    updateDate: Date;

    @DeleteDateColumn()   
    @Index()
    deletedDate: Date

    @VersionColumn()
    version: number

    @ManyToMany(() => Topic)
    @JoinTable()
    topics: Topic[]
}