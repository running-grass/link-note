import { Entity, JoinTable, ManyToMany, OneToMany, TableInheritance } from "typeorm";
import { Base } from "./base.entity";
import { Card } from "./card.entity";
@Entity()
@TableInheritance({ column: { type: "varchar", name: "type" } })
export class Node extends Base {
    @ManyToMany(() => Node)
    @JoinTable()
    tags: Node[]

    @OneToMany(() => Card, (card) => card.belong, {
    })
    cards: Card[]
}