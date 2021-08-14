module Main 
  where

import Control.Promise (Promise, toAffE)
import Data.Maybe (Maybe(..), maybe)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_, throwError)
import Effect.Class (liftEffect)
import Effect.Exception (error)
import Halogen as H
import Halogen.Aff (awaitLoad, runHalogenAff, selectElement)
import Halogen.VDom.Driver (runUI)
import LinkNote.Component.AppM (runAppM)
import LinkNote.Component.Router as Router
import LinkNote.Data.Route (routeCodec)
import LinkNote.Page.Home (Note, File)
import Prelude (Unit, bind, discard, pure, unit, void, when, ($), (/=))
import Routing.Duplex (parse)
import Routing.Hash (matchesWith)
import RxDB.Type (RxCollection, RxDatabase)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.HTML (HTMLElement)

foreign import initRxDB :: Unit -> Effect (Promise RxDatabase)

initRxDBA :: Unit -> Aff RxDatabase
initRxDBA unit = toAffE $ initRxDB unit

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
main = runHalogenAff do
    db <- initRxDBA unit
    coll <- getNotesCollectionA db    
    collFile <- getFileCollectionA db  
    app <- awaitRoot
    rootComponent <- runAppM {currentUser : Nothing} Router.component
    halogenIO <- runUI rootComponent { ipfs: Nothing , coll : coll, collFile : collFile } app
    void $ liftEffect $ matchesWith (parse routeCodec) \old new ->
      when (old /= Just new) do
        launchAff_ $ halogenIO.query $ H.mkTell $ Router.Navigate new
