module LinkNote.Component.Notification where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)

foreign import _requestPermission :: Effect (Promise Unit)

requestPermission :: Aff Unit
requestPermission  = toAffE  _requestPermission

foreign import notify :: String -> Effect Unit