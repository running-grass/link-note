module LinkNote.Capability.Resource.Topic where

import Prelude

import Halogen (HalogenM, lift)
import LinkNote.Data.Data (Topic)

class Monad m <= ManageTopic m where
  getTopics :: m (Array Topic)
  createTopic :: Topic -> m Unit

instance manageTopicHalogenM :: ManageTopic m => ManageTopic (HalogenM st act slots msg m) where
  getTopics = lift  getTopics
  createTopic = lift <<< createTopic