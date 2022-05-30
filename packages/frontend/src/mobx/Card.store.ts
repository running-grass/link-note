import { makeObservable, observable, action, computed } from "mobx"
import { TopicStore } from "./Topic.store"
import { sdk } from '../apollo'
import { CardType } from "../generated/graphql"
import { swapItem } from "../utils/array"
import { Guid } from "link-note-common"

export interface MinCard {
    id: Guid
    content: string
    childrens?: MinCard[]
    cardType: CardType
    [propName: string]: unknown
}

export class CardStore {
    readonly id: Guid
    @observable content: string
    @observable childrens: CardStore[]

    @observable parent?: CardStore
    @observable belong: TopicStore
    @observable cardType: CardType

    constructor(_card: MinCard, belong: TopicStore, parent?: CardStore) {

        this.id = _card.id
        this.content = _card.content
        this.childrens = _card.childrens?.map(_c => new CardStore(_c, belong, this)) ?? []

        this.parent = parent
        this.belong = belong
        this.cardType = _card.cardType

        makeObservable(this)
    }

    @computed
    get isEditing() {
        return this.belong.currentEditingCard === this;
    }

    @computed
    get level() {
        let parent = this.parent
        let level = 1
        while (parent) {
            level++
            parent = parent.parent
        }
        return level
    }

    @action
    async createNextCard(posStart: number, posEnd: number) {
        const content = this.content


        const min = Math.min(posStart, posEnd)
        const max = Math.max(posStart, posEnd)

        this.changeContent(content.slice(0, min))
        // this.content = 

        const nextContent = content.slice(max)

        const cardType = this.cardType;
        // }
        const { data } = await sdk.createNewCardMutation({
            variables: {
                belongId: this.belong.id,
                parentId: this.parent?.id,
                leftId: this.id,
                content: nextContent,
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

        this.belong.setNeedFocus({
            card: newCard,
            pos: 0
        })

        return newCard
    }

    // 更新content
    @action
    changeContent(content: string) {
        this.content = content;
        // this.belong.updateCardsToServer()
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
    navToPlantUp(): void {
        const prev = this.getPlantPrevCard()
        if (!prev) return

        this.belong.setNeedFocus({
            card: prev
        })
    }

    @action
    navToPlantDown(): void {
        const next = this.getPlantNextCard()
        if (!next) return

        this.belong.setNeedFocus({
            card: next
        })
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


    @action
    delete(): void {
        this.removeSelfFormParent()
        sdk.deleteCardMutation({
            variables: {
                cardId: this.id
            }
        })
    }

    @action
    async deleteAt(pos: number): Promise<number | null> {
        if (pos === 0) {
            this.backToPlantUp()
            return null
        } else {
            const arr = this.content.split('')
            arr.splice(pos - 1, 1)
            this.changeContent(arr.join(''))
            return pos - 1
        }
    }

    @action
    backToPlantUp(): void {
        const [, idx] = this.getHomesAndIdx()
        if (this.level === 1 && idx === 0) {
            return
        }

        let to: CardStore
        if (idx === 0) {
            to = this.parent!
        } else {
            to = this.getPlantPrevCard()!
        }

        for (const c of this.childrens) {
            c.parent = to
        }
        to.childrens = to.childrens.concat(this.childrens)
        this.removeSelfFormParent()

        // 计算光标位置
        const toContent = to.content
        const cnt = toContent.length
        to.changeContent(toContent + this.content)
        this.belong.setNeedFocus({
            card: to,
            pos: cnt
        })
    }

    private getPlantPrevCard(): CardStore | null {
        const plantCards = this.getRootPlantCardList()
        const idx = plantCards.findIndex(c => c === this)
        if (idx === -1) {
            throw new Error('idx不应当为-1')
        }

        if (idx === 0) {
            return null
        }

        return plantCards[idx - 1]
    }

    private getPlantNextCard(): CardStore | null {
        const plantCards = this.getRootPlantCardList()
        const idx = plantCards.findIndex(c => c === this)
        if (idx === -1) {
            throw new Error('idx不应当为-1')
        }

        if (idx === plantCards.length - 1) {
            return null
        }

        return plantCards[idx + 1]
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

    getSubPlantCardList(): CardStore[] {
        let arr: CardStore[] = []

        for (const card of this.childrens) {
            arr = arr.concat([card], card.getSubPlantCardList())
        }

        return arr
    }

    getSiblingPlantCardList(): CardStore[] {
        let arr: CardStore[] = []

        let siblings: CardStore[]
        if (this.parent) {
            siblings = this.parent.childrens
        } else {
            siblings = this.belong.cards
        }

        for (const card of siblings) {
            arr = arr.concat([card], card.getSubPlantCardList())
        }

        return arr
    }

    getRootPlantCardList(): CardStore[] {
        let arr: CardStore[] = []

        let siblings = this.belong.cards

        for (const card of siblings) {
            arr = arr.concat([card], card.getSubPlantCardList())
        }

        return arr
    }


}
