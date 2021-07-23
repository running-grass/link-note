module IPFS.Orbitdb where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import IPFS (IPFS)
import Option (Option, fromRecord)

foreign import data OrbitDB :: Type
foreign import data Keystore :: Type
foreign import data Cache :: Type
foreign import data Identity :: Type


type OrbitDBOption = Option 
    ( directory :: String
    , peerId :: String
    , keystore :: Keystore
    , cache :: Cache  
    , identity :: Identity
    , offline :: Boolean
)


data DBNameOrAddr = DBName String | DBAddr String

instance showDBNameOrAddr :: Show DBNameOrAddr where
    show (DBName x) = x 
    show (DBAddr y) = y


foreign import createInstance :: IPFS -> OrbitDBOption -> Effect (Promise OrbitDB)

createInstanceA :: IPFS -> OrbitDBOption -> Aff OrbitDB
createInstanceA ipfs option = toAffE $  createInstance ipfs option 

createInstanceA_ :: IPFS -> Aff OrbitDB
createInstanceA_ ipfs = createInstanceA ipfs (fromRecord {}) 

