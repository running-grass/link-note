module LinkNote.Page.TopicList where

import Prelude

import Data.Maybe (Maybe(..))
import Data.UUID as UUID
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML (HTML)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import LinkNote.Capability.Now (class Now, now)
import LinkNote.Capability.Resource.Note (class ManageNote)
import LinkNote.Capability.Resource.Topic (class ManageTopic, createTopic, getTopics)
import LinkNote.Component.HTML.Utils (buttonClass, css, inputClass, safeHref)
import LinkNote.Data.Data (Topic)
import LinkNote.Data.Route as LR

type Input = Unit

type State = { 
    newTopicName :: String
    , topicList :: Array Topic
}

data Action = 
  ChangeNewTopicName String
  | CreateTopic
  | UpdateTopicList

render :: forall cs m. State -> H.ComponentHTML Action cs m
render st =
  HH.section_ [
    HH.div_ [
      HH.input [ inputClass "mr-4", HP.value st.newTopicName, HE.onValueChange \topicName -> ChangeNewTopicName topicName ]
      , HH.button [ buttonClass "", HE.onClick \_ -> CreateTopic ] [HH.text "新建主题"]
    ] 
    , HH.ul_ $ st.topicList <#> renderItem
  ]

renderItem :: forall i p. Topic -> HTML i p
renderItem  topic  =
    HH.li_
      [ HH.a [ css "topic-item"
          , safeHref $ LR.Topic topic.id
          ]
          [ HH.text topic.name ]
      ]

handleAction :: forall cs o m . 
  MonadAff m =>  
  Now m => 
  ManageTopic m =>
  Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  ChangeNewTopicName newTopicName -> do 
    H.modify_ _ { newTopicName = newTopicName}
  CreateTopic -> do
    newTopicName <- H.gets _.newTopicName
    uuid <- H.liftEffect UUID.genUUID 
    let id = "topic-" <> UUID.toString uuid
    nowTime <- now
    let topic = {
      id : id
      , name : newTopicName
      , created : nowTime
      , updated : nowTime
      , noteIds : []
    }
    createTopic topic
    list <- getTopics
    H.modify_ _ { topicList = list, newTopicName = "" }
  UpdateTopicList -> do
    list <- getTopics
    H.modify_ _ { topicList = list }

initialState :: forall  a. a -> State
initialState _ = { 
  newTopicName : ""
  , topicList : []
}

component :: forall q  o m. 
  MonadAff m => 
  Now m => 
  ManageNote m =>
  ManageTopic m =>
  H.Component q Input o m
component = H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval { 
        handleAction = handleAction
        , initialize = Just UpdateTopicList
      }
    }
