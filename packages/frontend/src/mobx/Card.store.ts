import { makeObservable, observable, computed, action } from "mobx"
import { TopicStore } from "./Topic.store"
import { sdk } from '../apollo'
import { CardType } from "../generated/graphql"


export interface MinCard {
    id: number
    content: string
    childrens: MinCard[]
    cardType: CardType
    [propName: string]: unknown
}

export class CardStore {
    readonly id : number
    @observable content : string
    @observable childrens : CardStore[] 

    @observable parent? : CardStore
    @observable belong : TopicStore
    @observable cardType: CardType

    constructor(_card: MinCard, belong: TopicStore, parent?: CardStore) {
        makeObservable(this)

        this.id  = _card.id
        this.content = _card.content
        this.childrens = _card.childrens.map(_c => new CardStore(_c, belong, this))

        this.parent = parent
        this.belong = belong
        this.cardType = _card.cardType
    }

    @action
    async createNextCard(content: string = '', cardType?: CardType) {
        if (!cardType) {
            cardType = this.cardType;
        }
        await sdk.createNewCardMutation({
            variables: {
                belongId: this.belong.id,
                parentId: this.parent?.id,
                content,
                cardType,
            }
        })

        await this.belong.refresh();
    }
}
