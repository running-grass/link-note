module IPFS where

import Control.Promise (Promise, toAffE)
-- import Data.Function (($))
import Effect (Effect)
import Effect.Aff (Aff)
import Prelude 

-- data IPFS = IPFS
foreign import data IPFS :: Type

foreign import getIpfs :: Unit -> Effect (Promise IPFS)

getIpfs' :: Unit -> Aff IPFS
getIpfs' unit = toAffE $ getIpfs unit
