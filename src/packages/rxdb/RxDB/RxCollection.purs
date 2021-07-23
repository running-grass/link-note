module RxDB.RxCollection where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import RxDB.Type (RxCollection, RxDatabase, RxDocument)

foreign import getCollection :: RxDatabase -> String -> Effect (Promise RxCollection)

getCollectionA :: RxDatabase -> String -> Aff RxCollection
getCollectionA db collName = toAffE $ getCollection db collName

foreign import isRxCollection :: RxCollection -> Effect Boolean

foreign import insert :: forall json . RxCollection -> json -> Effect (Promise RxDocument)

insertA :: forall json . RxCollection -> json -> Aff RxDocument
insertA coll json = toAffE $ insert coll json