module RxDB.RxCollection where

import Prelude

import Control.Promise (Promise, toAffE)
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect.Aff (Aff)
import RxDB.Type (QueryObject, RxCollection, RxDatabase, RxDocument, RxQuery)

foreign import getCollection :: forall doc. RxDatabase -> String -> Effect (Promise (RxCollection doc))

getCollectionA :: forall doc. RxDatabase -> String -> Aff (RxCollection doc)
getCollectionA db collName = toAffE $ getCollection db collName

foreign import isRxCollection :: forall doc. RxCollection doc -> Effect Boolean

foreign import insert :: forall doc . RxCollection doc -> doc -> Effect (Promise (RxDocument doc))

insertA :: forall doc . RxCollection doc -> doc -> Aff (RxDocument doc)
insertA coll json = toAffE $ insert coll json

foreign import find :: forall doc . (RxCollection doc)-> QueryObject -> Effect (RxQuery (Array (RxDocument doc)))

foreign import findOne :: forall doc. RxCollection  doc -> QueryObject -> Effect (RxQuery (Maybe (RxDocument doc)))