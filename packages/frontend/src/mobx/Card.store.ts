import { makeObservable, observable, action } from "mobx"
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
        const { data } = await sdk.createNewCardMutation({
            variables: {
                belongId: this.belong.id,
                parentId: this.parent?.id,
                leftId: this.id,
                content,
                cardType,
            }
        })

        if (!data?.createNewCard) {
            console.error("插入新节点失败");
            return;
        }

        let homes: CardStore[]
        let currIdx: number
        if (this.parent) {
             currIdx = this.parent.childrens.findIndex(i => i === this);
            homes = this.parent.childrens
        } else { 
             currIdx = this.belong.cards.findIndex(i => i === this);
            homes = this.belong.cards
        }

        if (currIdx === -1) {
            console.error('当前Card不在其父节点的childrens中')
            return
        }

        const newCard = new CardStore({ ...data.createNewCard, childrens: [] }, this.belong, this.parent)
        
        homes.splice(currIdx + 1, 0, newCard)
    }

    // 更新content
    @action
    changeContent(content: string) {
        this.content = content;
        this.belong.updateCardsToServer()
    }
}
