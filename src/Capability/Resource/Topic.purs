module LinkNote.Capability.Resource.Topic where

import Prelude

import Data.Maybe (Maybe)
import Halogen (HalogenM, lift)
import LinkNote.Data.Data (Topic, TopicId)

class Monad m <= ManageTopic m where
  getTopics :: m (Array Topic)
  createTopic :: Topic -> m Unit
  getTopic :: TopicId -> m (Maybe Topic)
  updateTopicById :: forall r. TopicId -> Record r -> m Boolean

instance manageTopicHalogenM :: ManageTopic m => ManageTopic (HalogenM st act slots msg m) where
  getTopics = lift  getTopics
  createTopic = lift <<< createTopic
  getTopic = lift <<< getTopic
  updateTopicById id = lift <<< updateTopicById id