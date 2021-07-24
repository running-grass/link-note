module RxDB.RxDocument where

import Effect (Effect)
import RxDB.Type (RxDocument)

foreign import isRxDocument :: forall a. RxDocument a -> Effect Boolean

foreign import toJSON :: forall  a. RxDocument a -> Effect a