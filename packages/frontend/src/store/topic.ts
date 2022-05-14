import { makeObservable, observable, computed, action } from "mobx"
import { TopicDto } from "../generated/graphql"

class TopicEntity {
    constructor(topicDto: TopicDto) {
        makeObservable(this)
    }
}