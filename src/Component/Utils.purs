module LinkNote.Component.Util where

import Prelude

import Data.Maybe (Maybe(..), fromMaybe)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Prim.TypeError (class Warn, Text)
import RxDB.Type (RxCollection, RxDatabase)

foreign import logAny :: forall a. a -> a

foreign import _maybeToEffect :: forall a. (forall x.x -> Maybe x -> x) ->  Maybe a -> Effect a

liftMaybe :: forall m a. Warn (Text "这个方法不太好，逐渐弃用了！！！ by grass") 
    => MonadEffect m 
    => Maybe a -> m a 
liftMaybe mb = liftEffect $ _maybeToEffect fromMaybe mb 

foreign import _swapElem :: forall a . 
    (forall x. x -> Maybe x) 
    -> (forall x. Maybe x) 
    -> Int
    -> Int
    -> Array a
    -> Maybe (Array a)

swapElem :: forall a. Int -> Int -> Array a -> Maybe (Array a)
swapElem idx1 idx2 arr = _swapElem Just Nothing idx1 idx2 arr

foreign import refreshWindow :: Effect Unit


foreign import _getCollection :: forall a.  (forall x. x -> Maybe x) 
  -> (forall x. Maybe x) 
  -> RxDatabase 
  -> String 
  -> Effect (Maybe (RxCollection a))


getCollection :: forall a . RxDatabase -> String -> Effect (Maybe (RxCollection a))
getCollection = _getCollection Just Nothing
