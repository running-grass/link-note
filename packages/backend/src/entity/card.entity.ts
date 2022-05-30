import { CardType } from "src/enum/common";
import { Guid } from "src/util/type";
import { Column, Entity, Index, JoinColumn, JoinTable, ManyToOne, OneToOne, Tree, TreeChildren, TreeLevelColumn, TreeParent } from "typeorm";
import { Base } from "./base.entity";
import { Node } from './node.entity';
import { Topic } from "./topic.entity";
import { Workspace } from "./workspace.entity";

@Entity()
@Tree("closure-table")
export class Card  extends Base{
    @ManyToOne(() => Topic, node => node.cards)
    @Index()
    belong!: Topic

    @Column()
    content!: string

    @Column()
    cardType!: CardType

    @TreeParent()
    parent: Card

    @Column({nullable: true})
    leftId?: Guid

    @TreeChildren()
    childrens: Card[]

    @ManyToOne(() => Workspace, {nullable: false})
    @JoinColumn({name: 'wid'})
    @Index()
    workspace: Workspace
}