module LinkNote.Component.Util where

import Prelude

import Control.Promise (Promise, toAffE)
import Data.Maybe (Maybe, fromMaybe)
import Effect (Effect)
import Effect.Aff.Class (class MonadAff, liftAff)

foreign import logAny :: forall a. a -> a


foreign import _liftMaybeToPromise :: forall x . 
                                      (forall a. a → Maybe a → a)
                                      -> Maybe x 
                                      -> Effect (Promise x)

liftMaybe :: forall m a. MonadAff m => Maybe a -> m a 
liftMaybe mb = liftAff $ toAffE $ _liftMaybeToPromise (fromMaybe) mb
 