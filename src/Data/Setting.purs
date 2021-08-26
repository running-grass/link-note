module LinkNote.Data.Setting where

newtype IPFSApiAddress = IPFSApiAddress String

data IPFSInstanceType 
    = Unused
    | LocalIPFS
    | JsIPFS
    | BraveBrowser
    | WindowIPFS
    | CustomAPI IPFSApiAddress

toString :: IPFSInstanceType -> String 
toString = case _ of 
    Unused -> ""
    LocalIPFS -> "local"
    JsIPFS -> "js"
    BraveBrowser -> "brave"
    WindowIPFS -> "window"
    CustomAPI (IPFSApiAddress s) -> s

parseIpfsInsType :: String -> IPFSInstanceType
parseIpfsInsType = case _ of 
    "" -> Unused
    "local" -> LocalIPFS
    "js" -> JsIPFS
    "brave" -> BraveBrowser
    "window" -> WindowIPFS
    ad -> CustomAPI (IPFSApiAddress ad)