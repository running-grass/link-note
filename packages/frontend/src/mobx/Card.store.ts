import { makeObservable, observable, action, computed } from "mobx"
import { TopicStore } from "./Topic.store"
import { sdk } from '../apollo'
import { CardType } from "../generated/graphql"

export interface MinCard {
    id: number
    content: string
    childrens?: MinCard[]
    cardType: CardType
    [propName: string]: unknown
}

// 交换数组中的两个元素
const swapItem = (arr: any[], first: number, second: number): void => {
    if (!arr.length || first === second || first < 0 || second < 0 || first >= arr.length || second >= arr.length) {
        // 越界不处理
        return
    }

    const temp = arr[first]
    arr[first] = arr[second]
    arr[second] = temp
}

export class CardStore {
    readonly id: number
    @observable content: string
    @observable childrens: CardStore[]

    @observable parent?: CardStore
    @observable belong: TopicStore
    @observable cardType: CardType

    constructor(_card: MinCard, belong: TopicStore, parent?: CardStore) {
        makeObservable(this)

        this.id = _card.id
        this.content = _card.content
        this.childrens = _card.childrens?.map(_c => new CardStore(_c, belong, this)) ?? []

        this.parent = parent
        this.belong = belong
        this.cardType = _card.cardType
    }


    @computed
    get level() {
        console.log("Computing...")
        let parent = this.parent
        let level = 1
        while (parent) {
            level++
            parent = parent.parent
        }
        return level
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

    @action
    moveUp(): void {
        const [homes, idx] = this.getHomesAndIdx()
        if (idx <= 0) {
            return
        }
        swapItem(homes, idx, idx - 1)
    }

    @action
    moveDown(): void {
        const [homes, idx] = this.getHomesAndIdx()
        if (idx >= homes.length - 1) {
            return
        }
        swapItem(homes, idx, idx + 1)
    }

    @action
    moveLevelUp(): void {
        if (this.level === 1) {
            return
        }

        const [parenthomes, parentidx] = this.getParentHomesAndIdx()!

        this.removeSelfFormParent()

        parenthomes.splice(parentidx + 1, 0, this)
        this.parent = this.parent?.parent
    }



    @action
    moveLevelDown(): void {
        const [, idx] = this.getHomesAndIdx()

        if (idx === 0) {
            return
        }

        const prev = this.getPrevCard()!

        this.removeSelfFormParent()
        prev?.childrens.push(this)
        this.parent = prev
    }

    private getPrevCard(): CardStore | null {
        const [homes, idx] = this.getHomesAndIdx()
        return homes[idx - 1]
    }

    private getNextCard(): CardStore | null {
        const [homes, idx] = this.getHomesAndIdx()
        return homes[idx + 1]
    }

    private getParentPrevCard(): CardStore | null {
        const parents = this.getParentHomesAndIdx()
        if (!parents) return null
        const [homes, idx] = parents
        return homes[idx - 1]
    }

    private getParentNextCard(): CardStore | null {
        const parents = this.getParentHomesAndIdx()
        if (!parents) return null
        const [homes, idx] = parents
        return homes[idx + 1]
    }

    private getParentHomesAndIdx(): [CardStore[], number] | null {
        if (!this.parent) {
            // 没有父节点，就不会有叔父节点
            return null
        }

        let homes: CardStore[]

        const grandParent = this.parent.parent

        if (grandParent) {
            homes = grandParent.childrens
        } else {
            homes = this.belong.cards
        }

        let currIdx = homes.findIndex(i => i === this.parent);


        if (!homes.length) {
            throw new Error('当前Card的同级列表不应该为空')
        }

        if (currIdx === -1) {
            throw new Error('当前Card应该存在于同级列表中')
        }

        return [homes, currIdx]
    }

    private getHomesAndIdx(): [CardStore[], number] {
        let homes: CardStore[]
        if (this.parent) {
            homes = this.parent.childrens
        } else {
            homes = this.belong.cards
        }

        let currIdx: number = homes.findIndex(i => i === this);

        if (!homes.length) {
            throw new Error('当前Card的同级列表不应该为空')
        }

        if (currIdx === -1) {
            throw new Error('当前Card应该存在于同级列表中')
        }

        return [homes, currIdx]
    }

    private removeSelfFormParent(): void {
        const [homes, idx] = this.getHomesAndIdx()

        homes.splice(idx, 1)
    }

}
