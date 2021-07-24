module RxDB.RxQuery where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import RxDB.Type (QueryObject, RxQuery)


foreign import isRxQuery :: forall a. RxQuery a -> Effect Boolean


foreign import exec :: forall result. RxQuery result -> Effect (Promise result)

execA :: forall result. RxQuery result -> Aff result
execA query = toAffE $ exec query

foreign import emptyQueryObject :: QueryObject

foreign import primaryQuery :: String -> QueryObject