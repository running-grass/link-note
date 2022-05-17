import { CardType } from "src/enum/common";
import { Column, Entity, Index, ManyToOne, Tree, TreeChildren, TreeParent } from "typeorm";
import { Base } from "./base.entity";
import { Node } from './node.entity';
import { Topic } from "./topic.entity";

@Entity()
@Tree("closure-table")
export class Card  extends Base{
    @ManyToOne(() => Topic, node => node.cards)
    @Index()
    belong: Topic

    @Column()
    content: string

    @Column()
    cardType: CardType

    @TreeParent()
    parent: Card

    @TreeChildren()
    childrens: Card[]
}