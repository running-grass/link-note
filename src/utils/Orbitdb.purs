module Orbitdb where

import Effect (Effect)
import Prelude (Unit)

foreign import getdb :: String -> Effect Unit
