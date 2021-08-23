module LinkNote.Capability.ManageFile where

import Prelude

import Control.Monad.Trans.Class (lift)
import Halogen (HalogenM)
import LinkNote.Data.Data (File)

class Monad m <= ManageFile m where
  addFile :: File -> m Boolean

instance manageIPFSHalogenM :: ManageFile m => ManageFile (HalogenM st act slots msg m) where
  addFile = lift <<< addFile