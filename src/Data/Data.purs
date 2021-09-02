module LinkNote.Data.Data where

import Data.DateTime.Instant (Instant)

type Time = Instant
type NoteId = String
type FileId = String 
type TopicId = String

type HostType = String

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