module LinkNote.Capability.Resource.Note where

import Prelude

import Data.Array.NonEmpty (singleton)
import Data.Maybe (Maybe)
import Halogen (HalogenM, lift)
import LinkNote.Capability.Now (class Now, now)
import LinkNote.Capability.UUID (class UUID, genNoteId)
import LinkNote.Data.Data (Note, NoteId, TopicId)

class Monad m <= ManageNote m where
  addNote :: Note -> m (Maybe Note)
  deleteNotes :: Array NoteId -> m Boolean
  getAllNotesByHostId :: TopicId -> m (Array Note)
  updateNoteById :: forall r. NoteId -> Record r -> m Boolean
        
instance manageNoteHalogenM :: ManageNote m => ManageNote (HalogenM st act slots msg m) where
  addNote = lift <<< addNote
  deleteNotes = lift <<< deleteNotes
  getAllNotesByHostId = lift <<< getAllNotesByHostId
  updateNoteById id = lift <<< updateNoteById id


deleteNote :: forall m. ManageNote m => String -> m Boolean
deleteNote id = deleteNotes [id]


generateEmptyNote :: forall m . 
  UUID m 
  => Now m 
  => String -> String -> String  -> String -> m Note
generateEmptyNote hostType hostId parentId heading = do
  nowTime <- now
  id <- genNoteId
  pure {
    id,
    heading,
    content: "",
    hostType,
    hostId,
    created: nowTime,
    updated: nowTime,
    parentId,
    childrenIds: []
  }


createNewNote :: forall m . 
  UUID m 
  => Now m 
  => ManageNote m 
  => String -> String -> String  -> String -> m (Maybe Note)
createNewNote hostType hostId parentId heading = do
  nowTime <- now
  id <- genNoteId
  let note = {
    id,
    heading,
    content: "",
    hostType,
    hostId,
    created: nowTime,
    updated: nowTime,
    parentId,
    childrenIds: []
  }
  addNote note

createTopicNote :: forall m . 
  UUID m 
  => Now m 
  => ManageNote m 
  => String -> String  -> String -> m (Maybe Note)
createTopicNote = createNewNote "topic"