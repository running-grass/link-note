module LinkNote.Component.Util where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import RxDB.Type (RxCollection, RxDatabase)

foreign import logAnyE :: forall a. a -> Effect Unit

foreign import _maybeToEffect :: forall a. (forall x.x -> Maybe x -> x) ->  Maybe a -> Effect a

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
