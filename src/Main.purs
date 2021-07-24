module Main 
  where

import Prelude

import App (Note)
import App as App
import Control.Promise (Promise, toAffE)
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_, throwError)
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


foreign import getNotesCollection :: RxDatabase -> Effect (Promise (RxCollection Note))

getNotesCollectionA :: RxDatabase -> Aff (RxCollection Note)
getNotesCollectionA db = toAffE $ getNotesCollection db

-- | Waits for the document to load and then finds the `body` element.
awaitRoot :: Aff HTMLElement
awaitRoot = do
  awaitLoad
  ele <- selectElement (QuerySelector "#halogen-app")
  maybe (throwError (error "找不到根节点！")) pure ele

main :: Effect Unit
main = do
  launchAff_ do
    db <- initRxDBA unit
    coll <- getNotesCollectionA db  
    app <- awaitRoot
    runUI App.component { coll } app

