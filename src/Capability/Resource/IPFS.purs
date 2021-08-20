module LinkNote.Capability.ManageIPFS where

import Prelude

import Control.Monad.Trans.Class (lift)
import Halogen (HalogenM)

class Monad m <= ManageIPFS m where
  getIpfsGatewayPrefix :: m String

instance manageIPFSHalogenM :: ManageIPFS m => ManageIPFS (HalogenM st act slots msg m) where
  getIpfsGatewayPrefix = lift getIpfsGatewayPrefix