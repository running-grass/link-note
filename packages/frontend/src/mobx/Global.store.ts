import { makeObservable, observable } from "mobx"

import { sdk } from '../apollo';
import { UserDto } from  '../generated/graphql'
import { Guid } from 'link-note-common'

export let store : GlobalStore | null = null;

export class GlobalStore {
    @observable
    currUser: UserDto

    @observable
    currWorkspaceId: Guid

    constructor(user: UserDto) {
        this.currUser = user
        
        // TODO 从localstroage中取
        this.currWorkspaceId = user.workspaces[0].id
        
        makeObservable(this)
    }

    get workspaces() {
        return this.currUser.workspaces;
    }

    static async of() {
        if (store) {
            return store
        }

        const {data} = await sdk.currentUserQuery({})

        store = new GlobalStore(data.currentUser)

        return store;
    }
}
