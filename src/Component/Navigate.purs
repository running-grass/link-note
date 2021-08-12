module LinkNote.Component.Navigate where

import Prelude

import Control.Monad.Trans.Class (lift)
import Halogen (HalogenM)
import LinkNote.Data.Route (Route)

class Monad m <= Navigate m where
  navigate :: Route -> m Unit

-- | This instance lets us avoid having to use `lift` when we use these functions in a component.
instance navigateHalogenM :: Navigate m => Navigate (HalogenM st act slots msg m) where
  navigate = lift <<< navigate