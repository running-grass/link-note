import { makeObservable, observable, action } from "mobx"

import { sdk } from '../apollo';
import { UserDto, WorkspaceDto } from  '../generated/graphql'
import { TopicStore } from "./Topic.store";


let store : GlobalStore | null = null;

export class GlobalStore {
    @observable
    currUser: UserDto

    constructor(user: UserDto) {
        this.currUser = user
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
