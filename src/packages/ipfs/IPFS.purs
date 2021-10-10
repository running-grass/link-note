module IPFS where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import Option (Option, fromRecord)

-- data IPFS = IPFS
foreign import data IPFS :: Type

foreign import data CID :: Type
foreign import data PeerID :: Type
foreign import data IPFSRepo :: Type
foreign import data IPFSConfig :: Type

data IPFSRepoOption = IPFSRepoStr String | IPFSRepo

type IPFSOption = Option ( 
  config :: IPFSConfig,
  repo :: String
)

-- foreign import equals :: IPFS -> IPFS -> Boolean 

foreign import getDefaultIpfsConfig :: Unit -> IPFSConfig

-- 创建一个IPFS实例
foreign import create :: IPFSOption -> (Effect (Promise IPFS))

-- Aff版本
createA :: IPFSOption -> Aff IPFS
createA option = toAffE $ create $ option

createA_ :: Aff IPFS
createA_  = createA $ fromRecord {}

-- 创建一个全局IPFS实例
foreign import getGlobalIPFS :: Unit -> (Effect (Promise IPFS))

-- Aff版本
getGlobalIPFSA :: Unit -> Aff IPFS
getGlobalIPFSA unit = toAffE $ getGlobalIPFS unit


-- 版本信息
type VersionInfo = { commit :: String
  , "interface-ipfs-core" :: String
  , repo :: String
  , version :: String
}

foreign import version :: IPFS -> Effect (Promise VersionInfo)

versionA :: IPFS -> Aff VersionInfo
versionA ipfs = toAffE $ version ipfs
