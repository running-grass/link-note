module Orbitdb where


import Prelude

import Control.Monad.Trans.Class (lift)
import Control.Promise (Promise, toAffE)
import Data.Function.Uncurried (Fn2, runFn2)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Console (log, logShow)
import IPFS (IPFS, getIpfs, getIpfs')

foreign import data OrbitDB :: Type

-- type OrbitDBP = Promise Or

foreign import getdbByIpfs_ :: IPFS -> String -> (Effect (Promise OrbitDB))
foreign import saveVal_ :: String -> String -> (Effect Unit)
foreign import getVal_ :: String -> Effect String

getdbByIpfs :: IPFS -> String -> Aff OrbitDB
getdbByIpfs i dbname = toAffE $  getdbByIpfs_ i dbname

ipfs :: Aff IPFS
ipfs = getIpfs' unit

getdb :: String -> Effect Unit
getdb name = launchAff_ do 
    ipfs_ <- ipfs
    liftEffect $ logShow "ipfs_"
    _ <- getdbByIpfs ipfs_ name
    pure unit