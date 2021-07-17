module Orbitdb where

import Data.Function.Uncurried (Fn2, runFn2)
import Effect (Effect)
import Effect.Aff (Aff)
import IPFS (IPFS, getIpfs)
import Prelude (Unit, bind, unit)


foreign import getdbByIpfs_ :: Fn2 IPFS String (Effect Unit)
foreign import saveVal_ :: String -> String -> (Effect Unit)
foreign import getVal_ :: String -> Effect String

getdbByIpfs :: IPFS -> String -> Effect Unit
getdbByIpfs = runFn2 getdbByIpfs_

ipfs :: Effect IPFS
ipfs = getIpfs unit

getdb :: String -> Effect Unit
getdb name = do 
    ipfs_ <- ipfs
    getdbByIpfs ipfs_ name

