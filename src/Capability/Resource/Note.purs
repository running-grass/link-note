module LinkNote.Capability.Resource.Note where

import Prelude

import Halogen (HalogenM, lift)
import LinkNote.Data.Data (Note, NoteId, TopicId)

class Monad m <= ManageNote m where
  addNote :: Note -> m Boolean
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