module LinkNote.Data.Setting where

newtype IPFSApiAddress = IPFSApiAddress String

data IPFSInstanceType 
    = Unused
    | LocalIPFS
    | JsIPFS
    | BraveBrowser
    | WindowIPFS
    | CustomAPI IPFSApiAddress