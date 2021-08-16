module LinkNote.Page.TopicList where

import Prelude

import Data.Maybe (Maybe(..))
import Data.UUID as UUID
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML (HTML(..))
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Store.Connect (Connected, connect)
import Halogen.Store.Monad (class MonadStore)
import Halogen.Store.Select (selectAll)
import LinkNote.Capability.Now (class Now, now)
import LinkNote.Capability.Resource.Topic (class ManageTopic, createTopic, getTopics)
import LinkNote.Component.HTML.Utils (css, safeHref)
import LinkNote.Component.Store as LS
import LinkNote.Data.Data (Topic)
import LinkNote.Data.Route as LR
import RxDB.Type (RxCollection)

type Input = Unit

type ConnectedInput = Connected LS.Store Unit

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
      HH.input [ HP.value st.newTopicName, HE.onValueChange \topicName -> ChangeNewTopicName topicName ]
      , HH.button [ HE.onClick \_ -> CreateTopic ] [HH.text "新建主题"]
    ] 
    , HH.ul_ $ st.topicList <#> renderItem
  ]

renderItem :: forall i p. Topic -> HTML i p
renderItem  topic  =
    HH.li
      [ ]
      [ HH.a [ css "nav-link"  -- <> guard (route == r) " active"
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

initialState :: ConnectedInput-> State
initialState { context } = { 
  newTopicName : ""
  , topicList : []
}

component :: forall q  o m. 
  MonadStore LS.Action LS.Store m => 
  MonadAff m => 
  Now m => 
  ManageTopic m =>
  H.Component q Input o m
component = connect selectAll $
  H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval { 
        handleAction = handleAction
        , initialize = Just UpdateTopicList
      }
    }
