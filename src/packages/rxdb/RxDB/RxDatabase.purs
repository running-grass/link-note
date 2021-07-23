module RxDB.RxDatabase where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import RxDB.Type (RxDatabase)


foreign import isRxDatabase :: RxDatabase -> Effect Boolean


foreign import createRxDatabase :: forall a. a -> Effect (Promise RxDatabase)

createRxDatabaseA :: forall a. a -> Aff RxDatabase
createRxDatabaseA a = toAffE $ createRxDatabase a


foreign import addCollections :: forall a. RxDatabase -> a -> Effect (Promise Unit)

addCollectionsA :: forall a. RxDatabase -> a -> Aff Unit
addCollectionsA db a = toAffE $ addCollections db a


foreign import exportJSON :: forall a. RxDatabase -> Effect (Promise a)

exportJSONA :: forall a. RxDatabase -> Aff a
exportJSONA db = toAffE $ exportJSON db


foreign import importJSON :: forall a. RxDatabase -> a -> Effect (Promise Unit)

importJSONA :: forall a. RxDatabase -> a -> Aff Unit
importJSONA db json = toAffE $ importJSON db json


foreign import destroy :: RxDatabase -> Effect (Promise Unit)

destroyA :: RxDatabase -> Aff Unit
destroyA db = toAffE $ destroy db


foreign import remove :: RxDatabase -> Effect (Promise Unit)

removeA :: RxDatabase -> Aff Unit
removeA db = toAffE $ remove db 


foreign import requestIdlePromise :: RxDatabase -> Effect (Promise Unit)

requestIdlePromiseA :: RxDatabase -> Aff Unit
requestIdlePromiseA db = toAffE $ requestIdlePromise db 

