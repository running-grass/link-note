import { makeObservable, observable, action } from "mobx"
import { CardStore, MinCard } from "./Card.store"

import { sdk } from '../apollo';
import { CardType } from '../generated/graphql';
import { CardInputDto } from "../generated/apollo";

interface MinTopic {
    id: number
    title: string
    cards: MinCard[]

    [propName: string]: any
}

interface NeedFocusInfo {
    
        card: CardStore
        pos?: number
    
}
export class TopicStore {
    id!: number;

    @observable
    title!: string;

    @observable
    cards!: CardStore[];

    @observable
    needFocus?: NeedFocusInfo


    constructor(_topic: MinTopic) {
        makeObservable(this)
        this.initState(_topic);
    }

    @action
    private initState(_topic: MinTopic) {
        this.id = _topic.id
        this.title = _topic.title
        this.cards = _topic.cards.map(card => new CardStore(card, this))
    }

    @action
    changeTitle() {
        this.title = "i changeed"
    }

    @action
    clearNeedFocus() {
        this.needFocus = undefined
    }

    @action
    setNeedFocus(need: NeedFocusInfo) {
        this.needFocus = need
    }

    @action
    async refresh() {
        const { data: { topic } } = await sdk.findTopicQuery({ variables: { id: this.id } });
        if (!topic) {
            throw new Error('未能更新Topic')
        }
        this.initState(topic);
    }

    @action
    async updateCardsToServer() {
        await sdk.updateCardsMutation({
            variables: {
                cards: this.getInputDtos(this.cards)
            }
        })
    }


    @action
    async createNewRootCard() {
        await sdk.createNewCardMutation({
            variables: {
                belongId: this.id,
                parentId: null,
                content: '',
                cardType: CardType.Inline
            }
        })

        await this.refresh();
    }

    private getInputDtos(cards: CardStore[]): CardInputDto[] {
        if (!cards.length) return []

        return cards.map(card => ({
            id: card.id,
            cardType: card.cardType,
            content: card.content,
            childrens: card.childrens.length ? this.getInputDtos(card.childrens) : []
        }))
    }

    static async fromTitle(title: string): Promise<TopicStore | null> {
        const { data: { topic } } = await sdk.findTopicQuery({ variables: { title } });

        if (!topic) {

            return null;
        }

        return new TopicStore(topic);
    }
}
