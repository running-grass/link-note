module Test where

import Effect (Effect)
import Prelude (Unit)

foreign import write :: String -> Effect Unit

foreign import getdb :: String -> Effect Unit