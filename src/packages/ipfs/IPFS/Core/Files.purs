module IPFS.Core.Files where

import IPFS
import Prelude

import Control.Promise (Promise)
import Effect (Effect)
import Web.File.Blob (Blob)

foreign import data FileContent :: Type 

foreign import data FileConfig :: Type

foreign import data UnixFSEntry :: Type 

foreign import add :: IPFS -> FileContent -> FileConfig -> Effect (Promise UnixFSEntry)
