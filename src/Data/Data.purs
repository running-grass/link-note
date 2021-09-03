module LinkNote.Data.Data where

import Prelude

import Data.DateTime.Instant (Instant)
import Data.String.Regex (test)
import Data.String.Regex.Flags (global)
import Data.String.Regex.Unsafe (unsafeRegex)

type Time = Instant
type NoteId = String
type FileId = String 
type TopicId = String

type HostType = String

isTopicId :: String -> Boolean
isTopicId = test $ unsafeRegex "^topic-.*" global

isNoteId :: String -> Boolean
isNoteId = test $ unsafeRegex "^note-.*" global

type Note = {
  id :: NoteId
  , heading :: String
  , content :: String
  , hostType :: HostType
  , hostId :: String
  , created :: Time
  , updated :: Time 
  , parentId :: NoteId
  , childrenIds :: Array NoteId
}

type File = {
  id :: FileId
  , cid :: String
  , mime :: String
  , type :: String
  -- , created :: Time
  -- , updated :: Time 
  -- , noteIds :: Array NoteId
}

type Topic = {
  id :: TopicId,
  name :: String,
  created :: Time,
  updated :: Time,
  noteIds :: Array NoteId
}

type CollNames = (
  note :: String
  , topic :: String
  , file :: String
)

collNames :: Record CollNames
collNames = {
  note: "note"
  , topic: "topic"
  , file: "file"
}