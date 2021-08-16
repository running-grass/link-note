module LinkNote.Component.AppM where

import Prelude

import Control.Promise (Promise, toAffE)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Now as Now
import Halogen as H
import Halogen.Store.Monad (class MonadStore, StoreT, getStore, runStoreT)
import LinkNote.Capability.Navigate (class Navigate)
import LinkNote.Capability.Now (class Now)
import LinkNote.Capability.Resource.Note (class ManageNote)
import LinkNote.Capability.Resource.Topic (class ManageTopic)
import LinkNote.Component.Store as Store
import LinkNote.Data.Route as Route
import Routing.Duplex (print)
import Routing.Hash (setHash)
import RxDB.Type (RxCollection)
import Safe.Coerce (coerce)


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



foreign import _find :: forall a r. RxCollection a -> Record r -> Effect (Promise (Array a))

find :: forall a r. RxCollection a -> Record r -> Aff (Array a)
find coll q = toAffE $ _find coll q

foreign import _insertDoc :: forall a. RxCollection a -> a -> Effect (Promise Unit)

insertDoc :: forall a. RxCollection a -> a -> Aff Unit
insertDoc coll doc = toAffE $ _insertDoc coll doc

foreign import _updateDocById :: forall a doc. RxCollection a -> String -> doc -> Effect (Promise Unit)

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


instance manageTopicAppM :: ManageTopic AppM where
  getTopics = do
    { collTopic } <- getStore
    liftAff $ getAllDocs collTopic
  createTopic topic = do
    { collTopic } <- getStore 
    liftAff $ insertDoc collTopic topic
  getTopic id = do
    { collTopic } <- getStore 
    liftAff $ getDoc collTopic id

instance manageNoteAppM :: ManageNote AppM where
  addNote note = do
    { collNote } <- getStore
    liftAff $ insertDoc collNote note
    pure true
  deleteNote id = do
    { collNote } <- getStore
    liftAff $ bulkRemoveDoc collNote [id]
    pure true
  deleteNotes ids = do
    { collNote } <- getStore
    liftAff $ bulkRemoveDoc collNote ids
    pure true
  getAllNotesByHostId hostId = do
    { collNote } <- getStore
    liftAff $ find collNote { hostId } 
  updateNoteById id notePatch = do
    { collNote } <- getStore
    liftAff $ updateDocById collNote id notePatch
    pure true