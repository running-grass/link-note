module LinkNote.Capability.ManageStore where

import Prelude

import Control.Monad.Trans.Class (lift)
import Halogen (HalogenM)
import LinkNote.Data.Setting (IPFSInstanceType)

class Monad m <= ManageStore m where
  setIpfsInstanceType :: IPFSInstanceType ->  m Unit

instance ManageStore m => ManageStore (HalogenM st act slots msg m) where
  setIpfsInstanceType = lift <<< setIpfsInstanceType