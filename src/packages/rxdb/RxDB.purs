module RxDB where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import RxDB.Type (PouchPlugin)

foreign import addPouchPlugin :: PouchPlugin -> Effect Unit


foreign import checkAdapter :: String -> Effect (Promise Boolean)

checkAdapterA :: String -> Aff Boolean
checkAdapterA adapter = toAffE $ checkAdapter adapter


foreign import getPouchdbAdapterIdb :: forall a. Unit -> Effect a
