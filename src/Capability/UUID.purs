module LinkNote.Capability.UUID where

import Prelude

import Control.Monad.Trans.Class (lift)
import Halogen (HalogenM)
import LinkNote.Data.Data (TopicId, NoteId)

class Monad m <= UUID m where
  uuid :: m String

instance UUID m => UUID (HalogenM st act slots msg m) where
  uuid = lift uuid

genTopicId :: forall m . UUID m => m TopicId
genTopicId = do
  id <- uuid
  pure $ "topic-" <> id

genNoteId :: forall m . UUID m => m NoteId
genNoteId = do
  id <- uuid
  pure $ "note-" <> id