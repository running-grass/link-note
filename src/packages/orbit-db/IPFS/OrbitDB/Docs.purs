module IPFS.OrbitDB.Docs where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import IPFS.Orbitdb (DBNameOrAddr(..), OrbitDB)
import Option (Option, fromRecord)

foreign import data DocStore :: Type
-- foreign import data Doc :: Type

type Doc = {
    _id :: String
    , content :: String
}

type DocsOption = Option  ( indexBy :: String     )


foreign import docs :: OrbitDB -> String -> DocsOption -> Effect (Promise DocStore) 

docsA :: OrbitDB -> DBNameOrAddr -> DocsOption -> Aff DocStore
docsA orbitdb name option = toAffE $ docs orbitdb (show name) option 

docsA_ :: OrbitDB -> String -> Aff DocStore
docsA_ orbitdb name = docsA orbitdb (DBName name) (fromRecord {}) 

type DocKey = String
foreign import put :: DocStore  -> Doc -> Effect (Promise String)

putA :: DocStore -> Doc -> Aff String
putA db doc = toAffE $ put db doc

type DocResoult = Array Doc

foreign import get :: DocStore -> DocKey -> Effect DocResoult

-- getA :: DocStore -> DocKey -> Aff DocResoult
-- getA db key = toAffE $ get db key 


type Mapper = String 
foreign import query :: DocStore -> Mapper -> Effect (Promise DocResoult)

queryA :: DocStore -> Mapper -> Aff DocResoult
queryA db mapper = toAffE $ query db mapper

foreign import del :: DocStore -> DocKey -> Effect (Promise Unit)

delA :: DocStore -> DocKey -> Aff Unit
delA db key = toAffE $ del db key 