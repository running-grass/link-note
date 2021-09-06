module LinkNote.Capability.Resource.Topic where

import Prelude

import Data.Maybe (Maybe, isJust)
import Halogen (HalogenM, lift)
import LinkNote.Capability.Now (class Now, now)
import LinkNote.Capability.UUID (class UUID, genTopicId)
import LinkNote.Data.Data (TopicId, Topic)

class Monad m <= ManageTopic m where
  getTopics :: m (Array Topic)
  createTopic :: Topic -> m (Maybe Topic)
  getTopic :: TopicId -> m (Maybe Topic)
  updateTopicById :: forall r. TopicId -> Record r -> m Boolean
  getTopicByName :: String -> m (Maybe Topic)

instance manageTopicHalogenM :: ManageTopic m => ManageTopic (HalogenM st act slots msg m) where
  getTopics = lift  getTopics
  createTopic = lift <<< createTopic
  getTopic = lift <<< getTopic
  updateTopicById id = lift <<< updateTopicById id
  getTopicByName = lift <<< getTopicByName


createNewTopic :: forall m . 
  UUID m 
  => Now m 
  => ManageTopic m 
  => String -> m (Maybe Topic)
createNewTopic newTopicName = do
  maybeTopic <- getTopicByName newTopicName
  if isJust maybeTopic
  then pure maybeTopic
  else do
    id <- genTopicId
    nowTime <- now
    let topic = {
      id : id
      , name : newTopicName
      , created : nowTime
      , updated : nowTime
      , noteIds : []
    }
    createTopic topic