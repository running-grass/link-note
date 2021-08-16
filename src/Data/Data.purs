module LinkNote.Data.Data where

import Data.DateTime.Instant (Instant)

type Time = Instant
type NoteId = String
type FileId = String 
type TopicId = String

type HostType = String

type Note = {
  id :: NoteId
  , content :: String
  -- , heading :: String

  -- , hostType :: HostType
  -- , hostId :: String
  -- , created :: Time
  -- , updated :: Time 
  -- , childrenIds :: Array NoteId
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