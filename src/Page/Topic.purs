module LinkNote.Page.Topic where

import Prelude

import Data.Maybe (Maybe(..))
import Data.UUID as UUID
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Store.Connect (Connected, connect)
import Halogen.Store.Monad (class MonadStore)
import Halogen.Store.Select (selectAll)
import LinkNote.Capability.Now (class Now, now)
import LinkNote.Capability.Resource.Topic (class ManageTopic, createTopic, getTopic, getTopics)
import LinkNote.Component.Store as LS
import LinkNote.Data.Data (Topic, TopicId)
import RxDB.Type (RxCollection)

type Input = {
  topicId :: TopicId
}

type State = { 
  topicId :: TopicId
  , topic :: Maybe Topic
}

data Action = 
  UpdateTopic

render :: forall cs m. State -> H.ComponentHTML Action cs m
render st =
  HH.section_ [
    case st.topic of
    Nothing -> HH.text "主题不存在"
    Just topic -> HH.text topic.name
  ]

handleAction :: forall cs o m . 
  MonadAff m =>  
  Now m => 
  ManageTopic m =>
  Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  UpdateTopic -> do
    topicId <- H.gets _.topicId
    topic' <- getTopic topicId
    H.modify_ _ { topic = topic' }

initialState :: Input-> State
initialState input = { 
  topicId : input.topicId
  , topic : Nothing
}

component :: forall q  o m. 
  MonadStore LS.Action LS.Store m => 
  MonadAff m => 
  Now m => 
  ManageTopic m =>
  H.Component q Input o m
component = 
  H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval { 
        handleAction = handleAction
        , initialize = Just UpdateTopic
      }
    }
