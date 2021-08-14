module LinkNote.Data.Data where

type Note =  NoteBase ()

type NoteBase r = {
  id :: String , 
  content :: String| r
}

type NoteExtend = NoteBase (created :: Int)

type File = Record (
  id :: String , 
  cid :: String, 
  mime :: String,
  type :: String 
)