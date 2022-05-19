import { makeObservable, observable, action } from "mobx"
import { CardStore, MinCard } from "./Card.store"

import { sdk } from '../apollo';
import { CardType } from '../generated/graphql';

interface MinTopic {
    id: number
    title: string
    cards: MinCard[]
    [propName: string]: any
}

export class TopicStore {
    id!: number;

    @observable
    title!: string;

    @observable
    cards!: CardStore[];


    constructor(_topic: MinTopic) {
        makeObservable(this)
        this.initState(_topic);
    }

    @action
    private initState(_topic: MinTopic) {
        this.id  = _topic.id
        this.title = _topic.title
        this.cards = _topic.cards.map(card => new CardStore(card, this))
    }

    @action
    changeTitle() {
        this.title = "i changeed"
    }

    @action
    async refresh() {
        const { data: { topic } } = await sdk.findTopicQuery({variables: { id: this.id }});
        if (!topic) {
            throw new Error('未能更新Topic')
        }
        this.initState(topic);
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

    static async fromTitle(title: string): Promise<TopicStore | null> {
        const { data: { topic } } = await sdk.findTopicQuery({variables: { title }});

        if (!topic) {
            return null;
        }

        return new TopicStore(topic);
    }
}
