module Main 
  where

import IPFS
import Prelude

import App (Note, File)
import App as App
import Control.Promise (Promise, toAffE)
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_, throwError)
import Effect.Class (liftEffect)
import Effect.Exception (error)
import Halogen.Aff (awaitLoad, selectElement)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import RxDB.Type (RxCollection, RxDatabase)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.HTML (HTMLElement)

foreign import logAny :: forall a . a -> Effect Unit

foreign import initRxDB :: Unit -> Effect (Promise RxDatabase)

initRxDBA :: Unit -> Aff RxDatabase
initRxDBA unit = toAffE $ initRxDB unit


foreign import getGlobalIPFS :: Effect (Promise IPFS)

getGlobalIPFSA ::  Aff IPFS
getGlobalIPFSA  = toAffE $ getGlobalIPFS 

foreign import getNotesCollection :: RxDatabase -> Effect (Promise (RxCollection Note))
getNotesCollectionA :: RxDatabase -> Aff (RxCollection Note)
getNotesCollectionA db = toAffE $ getNotesCollection db

foreign import getFileCollection :: RxDatabase -> Effect (Promise (RxCollection File))
getFileCollectionA :: RxDatabase -> Aff (RxCollection File)
getFileCollectionA db = toAffE $ getFileCollection db

-- | Waits for the document to load and then finds the `body` element.
awaitRoot :: Aff HTMLElement
awaitRoot = do
  awaitLoad
  ele <- selectElement (QuerySelector "#halogen-app")
  maybe (throwError (error "找不到根节点！")) pure ele

main :: Effect Unit
main = do
  launchAff_ do
    ipfs <- getGlobalIPFSA
    db <- initRxDBA unit
    coll <- getNotesCollectionA db    
    collFile <- getFileCollectionA db  
    app <- awaitRoot
    runUI App.component { ipfs , coll, collFile } app
  pure unit
