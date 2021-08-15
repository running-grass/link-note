module LinkNote.Component.AppM where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Now as Now
import Halogen as H
import Halogen.Store.Monad (class MonadStore, StoreT, getStore, runStoreT)
import LinkNote.Capability.Navigate (class Navigate)
import LinkNote.Capability.Now (class Now)
import LinkNote.Capability.Resource.Topic (class ManageTopic)
import LinkNote.Component.Store as Store
import LinkNote.Data.Route as Route
import Routing.Duplex (print)
import Routing.Hash (setHash)
import RxDB.Type (RxCollection)
import Safe.Coerce (coerce)

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

foreign import _getAllDocs :: forall a. RxCollection a -> Effect (Promise (Array a))

getAllDocs :: forall a. RxCollection a -> Aff (Array a)
getAllDocs = toAffE <<< _getAllDocs

foreign import _insertDoc :: forall a. RxCollection a -> a -> Effect (Promise Unit)

insertDoc :: forall a. RxCollection a -> a -> Aff Unit
insertDoc coll doc = toAffE $ _insertDoc coll doc

instance manageTopicAppM :: ManageTopic AppM where
  getTopics = do
    { collTopic } <- getStore
    liftAff $ getAllDocs collTopic
  createTopic topic = do
    { collTopic } <- getStore 
    liftAff $ insertDoc collTopic topic
