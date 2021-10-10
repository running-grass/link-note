module IPFS.Core.Files where

import IPFS (IPFS)

import Control.Promise (Promise)
import Effect (Effect)

foreign import data FileContent :: Type 

foreign import data FileConfig :: Type

foreign import data UnixFSEntry :: Type 

foreign import add :: IPFS -> FileContent -> FileConfig -> Effect (Promise UnixFSEntry)
