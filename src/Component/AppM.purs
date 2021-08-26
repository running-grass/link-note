module LinkNote.Component.AppM where

import Prelude

import Control.Promise (Promise, toAffE)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console as Console
import Effect.Now as Now
import Halogen as H
import Halogen.Store.Monad (class MonadStore, StoreT, getStore, runStoreT)
import IPFS (IPFS)
import LinkNote.Capability.LogMessages (class LogMessages)
import LinkNote.Capability.ManageDB (class ManageDB)
import LinkNote.Capability.ManageFile (class ManageFile)
import LinkNote.Capability.ManageIPFS (class ManageIPFS)
import LinkNote.Capability.Navigate (class Navigate)
import LinkNote.Capability.Now (class Now)
import LinkNote.Capability.Resource.Note (class ManageNote)
import LinkNote.Capability.Resource.Topic (class ManageTopic)
import LinkNote.Component.Store (LogLevel(..))
import LinkNote.Component.Store as Store
import LinkNote.Component.Util (liftMaybe)
import LinkNote.Data.Log as Log
import LinkNote.Data.Route as Route
import Routing.Duplex (print)
import Routing.Hash (setHash)
import RxDB.Type (RxCollection, RxDatabase)
import Safe.Coerce (coerce)


foreign import _getGatewayUri :: 
  (forall x. x -> Maybe x) 
  -> (forall x. Maybe x) 
  -> IPFS
  -> Effect(Promise (Maybe String))

getGatewayUri :: IPFS -> Aff (Maybe String)
getGatewayUri ipfs = toAffE $ _getGatewayUri Just Nothing ipfs

foreign import _log :: forall a. a -> Effect Unit

foreign import _getDoc :: forall a id. 
  (forall x. x -> Maybe x) 
  -> (forall x. Maybe x) 
  -> RxCollection a 
  -> id
  -> Effect(Promise (Maybe a))

getDoc :: forall a id. RxCollection a -> id -> Aff (Maybe a)
getDoc coll id = toAffE $ _getDoc Just Nothing coll id

foreign import _getAllDocs :: forall a. RxCollection a -> Effect (Promise (Array a))

getAllDocs :: forall a. RxCollection a -> Aff (Array a)
getAllDocs = toAffE <<< _getAllDocs

foreign import _deleteDB :: RxDatabase -> Effect (Promise Unit)
foreign import _exportDB :: RxDatabase -> Effect (Promise Unit)

deleteDB :: RxDatabase -> Aff Unit
deleteDB = toAffE <<< _deleteDB

exportDB :: RxDatabase -> Aff Unit
exportDB = toAffE <<< _exportDB

foreign import _find :: forall a r. RxCollection a -> Record r -> Effect (Promise (Array a))

find :: forall a r. RxCollection a -> Record r -> Aff (Array a)
find coll q = toAffE $ _find coll q

foreign import _insertDoc :: forall a. RxCollection a -> a -> Effect (Promise Unit)

insertDoc :: forall a. RxCollection a -> a -> Aff Unit
insertDoc coll doc = toAffE $ _insertDoc coll doc

foreign import _updateDocById :: forall a doc. RxCollection a -> String -> doc -> Effect (Promise Unit)

updateDocById :: forall a doc. RxCollection a -> String -> doc -> Aff Unit
updateDocById coll id doc = toAffE $ _updateDocById coll id doc

foreign import _bulkRemoveDoc :: forall a id. RxCollection a -> Array id -> Effect (Promise Unit)

bulkRemoveDoc :: forall a id. RxCollection a -> Array id -> Aff Unit
bulkRemoveDoc coll ids = toAffE $ _bulkRemoveDoc coll ids


newtype AppM a = AppM (StoreT Store.Action Store.Store Aff a)

runAppM :: forall q i o. Store.Store -> H.Component q i o AppM -> Aff (H.Component q i o Aff)
runAppM store = runStoreT store Store.reduce <<< coerce

derive newtype instance functorAppM :: Functor AppM
derive newtype instance applyAppM :: Apply AppM
derive newtype instance applicativeAppM :: Applicative AppM
derive newtype instance bindAppM :: Bind AppM
derive newtype instance monadAppM :: Monad AppM
derive newtype instance monadEffectAppM :: MonadEffect AppM
derive newtype instance monadAffAppM :: MonadAff AppM
derive newtype instance monadStoreAppM :: MonadStore Store.Action Store.Store AppM

instance navigateAppM :: Navigate AppM where
  navigate =
    liftEffect <<< setHash <<< print Route.routeCodec

instance nowAppM :: Now AppM where
  now = liftEffect Now.now
  nowDate = liftEffect Now.nowDate
  nowTime = liftEffect Now.nowTime
  nowDateTime = liftEffect Now.nowDateTime

instance ipfsAppM :: ManageIPFS AppM where
  getIpfsGatewayPrefix = do 
    { ipfs } <- getStore
    let default = pure "https://dweb.link/ipfs/"
    case ipfs of 
      Nothing -> default
      Just ipfs' -> do
        uri <- liftAff $ getGatewayUri ipfs'
        case uri of 
          Nothing -> default
          Just uri' -> pure uri'

instance manageTopicAppM :: ManageTopic AppM where
  getTopics = do
    { collTopic } <- getStore
    coll <- liftMaybe collTopic
    liftAff $ getAllDocs coll
  createTopic topic = do
    { collTopic } <- getStore 
    coll <- liftMaybe collTopic
    liftAff $ insertDoc coll topic
  getTopic id = do
    { collTopic } <- getStore 
    coll <- liftMaybe collTopic
    liftAff $ getDoc coll id
  updateTopicById id patch = do
    { collTopic } <- getStore
    coll <- liftMaybe collTopic
    liftAff $ updateDocById coll id patch
    pure true
instance manageNoteAppM :: ManageNote AppM where
  addNote note = do
    { collNote } <- getStore
    coll <- liftMaybe collNote
    liftAff $ insertDoc coll note
    pure true
  deleteNotes ids = do
    { collNote } <- getStore
    coll <- liftMaybe collNote
    liftAff $ bulkRemoveDoc coll ids
    pure true
  getAllNotesByHostId hostId = do
    { collNote } <- getStore
    coll <- liftMaybe collNote
    liftAff $ find coll { hostId } 
  updateNoteById id notePatch = do
    { collNote } <- getStore
    coll <- liftMaybe collNote
    liftAff $ updateDocById coll id notePatch
    pure true

instance manageFileAppM :: ManageFile AppM where
  addFile file = do
    { collFile } <- getStore
    coll <- liftMaybe collFile
    liftAff $ insertDoc coll file
    pure true

instance logMessagesAppM :: LogMessages AppM where
  logMessage log = do
    { logLevel } <- getStore
    liftEffect case logLevel, Log.reason log of
      Prod, Log.Debug -> pure unit
      _, _ -> Console.log $ Log.message log
  logAny = H.liftEffect <<< _log

instance ManageDB AppM where
  deleteLocalDB = do
    { rxdb } <- getStore
    liftAff $ deleteDB rxdb
  exportLocalDB = do
    { rxdb } <- getStore
    liftAff $ exportDB rxdb

