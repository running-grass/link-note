module LinkNote.Capability.Resource.Note where

import Prelude

import Halogen (HalogenM, lift)
import LinkNote.Data.Data (Note, NoteId, TopicId)

class Monad m <= ManageNote m where
  addNote :: Note -> m Boolean
  deleteNote :: NoteId -> m Boolean
  deleteNotes :: Array NoteId -> m Boolean
  getAllNotesByHostId :: TopicId -> m (Array Note)
        
instance manageNoteHalogenM :: ManageNote m => ManageNote (HalogenM st act slots msg m) where
  addNote = lift <<< addNote
  deleteNote = lift <<< deleteNote
  deleteNotes = lift <<< deleteNotes
  getAllNotesByHostId = lift <<< getAllNotesByHostId