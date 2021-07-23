module RxDB.RxCollection where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import RxDB.Type (RxCollection, RxDatabase)

foreign import getCollection :: RxDatabase -> String -> Effect (Promise RxCollection)

getCollectionA :: RxDatabase -> String -> Aff RxCollection
getCollectionA db collName = toAffE $ getCollection db collName