module LinkNote.Component.Util where

import Prelude

import Data.Maybe (Maybe(..), fromJust, fromMaybe)
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect, liftEffect)
import Partial.Unsafe (unsafePartial)

foreign import logAny :: forall a. a -> a

foreign import _maybeToEffect :: forall a. (forall x.x -> Maybe x -> x) ->  Maybe a -> Effect a

liftMaybe :: forall m a. MonadEffect m => Maybe a -> m a 
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