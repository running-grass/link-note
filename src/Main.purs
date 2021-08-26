module Main 
  where

import Prelude

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
import LinkNote.Component.Store (LogLevel(..))
import LinkNote.Component.Store as Store
import LinkNote.Data.Route (routeCodec)
import LinkNote.Data.Setting (IPFSInstanceType(..), parseIpfsInsType)
import Routing.Duplex (parse)
import Routing.Hash (matchesWith)
import RxDB.Type (RxCollection, RxDatabase)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.HTML (HTMLElement)
import Web.HTML (window)
import Web.HTML.Window (localStorage)
import Web.Storage.Storage (clear, getItem, removeItem, setItem)


foreign import initRxDB :: Unit -> Effect (Promise RxDatabase)

initRxDBA :: Unit -> Aff RxDatabase
initRxDBA unit = toAffE $ initRxDB unit

foreign import _getCollection :: forall a.  (forall x. x -> Maybe x) 
  -> (forall x. Maybe x) 
  -> RxDatabase 
  -> String 
  -> Effect (Maybe (RxCollection a))

foreign import _initCollections :: RxDatabase -> Effect (Promise Boolean)

getCollection :: forall a . RxDatabase -> String -> Effect (Maybe (RxCollection a))
getCollection = _getCollection Just Nothing

initCollection :: RxDatabase -> Aff Boolean
initCollection = toAffE <<< _initCollections 

-- | Waits for the document to load and then finds the `body` element.
awaitRoot :: Aff HTMLElement
awaitRoot = do
  awaitLoad
  ele <- selectElement (QuerySelector "#halogen-app")
  maybe (throwError (error "找不到根节点！")) pure ele

main :: Effect Unit
main = runHalogenAff do
    app <- awaitRoot 
    db <- initRxDBA unit 
    void $ initCollection db
    collNote <- H.liftEffect $ getCollection db "note"
    collTopic <- H.liftEffect $ getCollection db "topic"
    collFile <- H.liftEffect $ getCollection db "file"
    w <- liftEffect window
    s <- liftEffect $ localStorage w
    str <- liftEffect $ getItem "ipfsInstanceType" s
    let insType = case str of 
                    Just sss -> parseIpfsInsType sss 
                    Nothing -> Unused
    let 
      initStore :: Store.Store
      initStore = {
        ipfs : Nothing
        , ipfsType : insType
        , rxdb : db
        , logLevel : Dev
        , collTopic : collTopic 
        , collNote : collNote
        , collFile : collFile
      } 
    rootComponent <- runAppM initStore Router.component 
    halogenIO <- runUI rootComponent unit app 
    void $ liftEffect $ matchesWith (parse routeCodec) \old new ->
      when (old /= Just new) do
        launchAff_ $ halogenIO.query $ H.mkTell $ Router.Navigate new