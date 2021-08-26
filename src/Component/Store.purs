module LinkNote.Component.Store where

import Prelude

import Data.Maybe (Maybe(..))
import IPFS (IPFS)
import LinkNote.Data.Data (Note, File, Topic)
import RxDB.Type (RxCollection, RxDatabase)

data LogLevel = Dev | Prod

derive instance eqLogLevel :: Eq LogLevel
derive instance ordLogLevel :: Ord LogLevel

type Store = { 
    ipfs :: Maybe IPFS
    , rxdb :: RxDatabase
    , logLevel :: LogLevel
    , collTopic :: Maybe (RxCollection Topic)
    , collNote :: Maybe (RxCollection Note)
    , collFile :: Maybe (RxCollection File)
  }

data Action
  = SetIPFS IPFS 
  | ClearIPFS

-- | Finally, we'll map this action to a state update in a function called a
-- | 'reducer'. If you're curious to learn more, see the `halogen-store`
-- | documentation!
reduce :: Store -> Action -> Store
reduce store = case _ of
  SetIPFS ipfs -> store { ipfs = Just ipfs }
  ClearIPFS -> store { ipfs = Nothing }