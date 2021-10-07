module LinkNote.Data.Data where

import Prelude

import Data.Array.NonEmpty (NonEmptyArray)
import Data.DateTime.Instant (Instant)
import Data.String.Regex (test)
import Data.String.Regex.Flags (global)
import Data.String.Regex.Unsafe (unsafeRegex)
import Web.HTML (HTMLElement)

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

-- 焦点元素的激活位置和前后文本
type CaretInfo = {
  position :: Int
  , element :: HTMLElement
  , beforeText :: String
  , afterText :: String
}

-- 各种的x，y坐标
type Point = {
  x :: Number
  , y :: Number
}

