module IPFS where

import Effect (Effect)
import Prelude (Unit)

data IPFS = IPFS

foreign import getIpfs :: Unit -> Effect IPFS