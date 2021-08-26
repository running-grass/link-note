module LinkNote.Capability.ManageDB where

import Prelude

import Control.Monad.Trans.Class (lift)
import Halogen (HalogenM)

class Monad m <= ManageDB m where
  deleteLocalDB :: m Unit
  exportLocalDB :: m Unit

instance nowHalogenM :: ManageDB m => ManageDB (HalogenM st act slots msg m) where
  deleteLocalDB = lift deleteLocalDB
  exportLocalDB = lift exportLocalDB