import { Entity, Index, JoinColumn, JoinTable, ManyToMany, ManyToOne, OneToMany, TableInheritance } from "typeorm";
import { Base } from "./base.entity";
import { Card } from "./card.entity";
import { Workspace } from "./workspace.entity";

@Entity()
@TableInheritance({ column: { type: "varchar", name: "type" } })
export class Node extends Base {
    @ManyToMany(() => Node)
    @JoinTable()
    tags: Node[]

    @OneToMany(() => Card, (card) => card.belong)
    cards: Card[]

    @ManyToOne(() => Workspace, {nullable: false})
    @JoinColumn({name: 'wid'})
    @Index()
    workspace: Workspace

}