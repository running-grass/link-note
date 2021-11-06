module LinkNote.Page.Router where

import Prelude

import Control.Monad.Error.Class (class MonadThrow, throwError)
import Control.Promise (Promise, toAffE)
import Data.Either (hush)
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff (Aff, Error, error)
import Effect.Aff.Class (class MonadAff)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.Hooks (type (<>), Hook, HookM, UseEffect, UseState)
import Halogen.Hooks as Hooks
import Halogen.Query.Event (eventListener)
import Halogen.Store.Connect (Connected, connect)
import Halogen.Store.Monad (class MonadStore, getStore, updateStore)
import Halogen.Store.Select (selectAll)
import IPFS (IPFS)
import LinkNote.Capability.LogMessages (class LogMessages, logAnyM)
import LinkNote.Capability.ManageDB (class ManageDB)
import LinkNote.Capability.ManageFile (class ManageFile)
import LinkNote.Capability.ManageHTML (class ManageHTML)
import LinkNote.Capability.ManageIPFS (class ManageIPFS)
import LinkNote.Capability.ManageStore (class ManageStore)
import LinkNote.Capability.Navigate (class Navigate, navigate)
import LinkNote.Capability.Now (class Now)
import LinkNote.Capability.Resource.Note (class ManageNote)
import LinkNote.Capability.Resource.Topic (class ManageTopic, createNewTopic, getTopic)
import LinkNote.Capability.UUID (class UUID)
import LinkNote.Component.HTML.Header (header)
import LinkNote.Component.HTML.Helper (helperHTML)
import LinkNote.Component.Store as Store
import LinkNote.Data.Data (isTopicId)
import LinkNote.Data.Data as Data
import LinkNote.Data.Route (Route(..), routeCodec)
import LinkNote.Data.Setting (IPFSApiAddress(..), IPFSInstanceType(..))
import LinkNote.Page.Home as Home
import LinkNote.Page.Setting as Setting
import LinkNote.Page.Topic as Topic
import LinkNote.Page.TopicList as TopicList
import Routing.Duplex as RD
import Routing.Hash (getHash)
import Type.Proxy (Proxy(..))
import Web.Event.Event as Event
import Web.HTML (Window, window)
import Web.HTML.Window as Window



type OpaqueSlot slot = forall query. H.Slot query Void slot

type Input = Unit 

type ConnectedInput = Connected Store.Store Input

foreign import getGlobalIPFS :: (forall x. x -> Maybe x) 
                                -> (forall x. Maybe x) 
                                -> String 
                                -> Effect (Promise (Maybe IPFS))



getGlobalIPFSA :: String -> Aff (Maybe IPFS)
getGlobalIPFSA addr = toAffE $ getGlobalIPFS Just Nothing addr

getIpfsAddrByType :: IPFSInstanceType -> String
getIpfsAddrByType Unused = "none"
getIpfsAddrByType WindowIPFS = "window"
getIpfsAddrByType JsIPFS = "js"
getIpfsAddrByType LocalIPFS = "http://127.0.0.1:5001/"
getIpfsAddrByType BraveBrowser = "http://127.0.0.1:45005/"
getIpfsAddrByType (CustomAPI  (IPFSApiAddress addr)) = addr

currentIpfs :: IPFSInstanceType
currentIpfs = Unused

data Query a
  = Navigate Route a

type State = { 
    route :: Maybe Route
    , ipfsInstanceType :: IPFSInstanceType
    , currentTopic :: Maybe Data.Topic
  }

data Action
  = Init
  | InitIPFS

type ChildSlots =
  ( home :: OpaqueSlot Unit
  , setting :: OpaqueSlot Unit
  , topicList :: OpaqueSlot Unit
  , topic :: OpaqueSlot Unit
  , pomodoro :: OpaqueSlot Unit
  )

initialState :: ConnectedInput -> State
initialState { context } = { 
  route: Nothing
  , ipfsInstanceType : context.ipfsType
  , currentTopic : Nothing
}

component :: forall m. MonadAff m
  => MonadStore Store.Action Store.Store m
  => Navigate m
  => ManageTopic m
  => Now m 
  => UUID m
  => MonadThrow Error m
  => ManageIPFS m
  => ManageNote m  
  => ManageFile m
  => ManageHTML m
  => ManageStore m
  => ManageDB m
  => LogMessages m
  => H.Component Query Input Void m
component = connect selectAll $ H.mkComponent
  { 
    initialState
  , render
  , eval: H.mkEval $ H.defaultEval
      { handleQuery = handleQuery
      , handleAction = handleAction
      , initialize = Just Init
      }
  }
  where
  handleAction :: Action -> H.HalogenM State Action ChildSlots Void m Unit
  handleAction = case _ of
    Init -> do
      initialRoute <- hush <<< (RD.parse routeCodec) <$> liftEffect getHash
      navigate $ fromMaybe Home initialRoute
      handleAction InitIPFS
    InitIPFS -> do
      { ipfsType } <- getStore
      logAnyM ipfsType
      let addr = getIpfsAddrByType ipfsType
      ipfs <- H.liftAff $ getGlobalIPFSA addr
      case ipfs of 
        Just ipfs' -> updateStore $ Store.SetIPFS ipfs'
        Nothing -> pure unit

  handleQuery :: forall a. Query a -> H.HalogenM State Action ChildSlots Void m (Maybe a)
  handleQuery = case _ of
    Navigate dest a -> do
      { route } <-  H.get
      when (route /= Just dest) do 
        logAnyM dest
        case dest of 
          Topic topicId -> do 
            if (isTopicId topicId)
            then do
              topic <- getTopic topicId
              H.modify_ _ { currentTopic = topic, route = Just $ Topic topicId}
            else do
              let topicName = topicId
              topic2' <- createNewTopic topicName
              case topic2' of
                Just topic2 -> navigate $ Topic topic2.id
                Nothing -> throwError $ error "创建主题失败"
          _ -> H.modify_ _ { route = Just dest }
      pure (Just a)

  render :: State -> H.ComponentHTML Action ChildSlots m
  render { route, ipfsInstanceType, currentTopic } = HH.div_ [
    header route,
    HH.slot_ (Proxy :: _ "pomodoro") unit myComponent unit,
    helperHTML,
    case route, currentTopic of
      Just (Topic topicId),Just topic -> HH.slot_ (Proxy :: _ "topic") unit Topic.component { topicId, topic }
      Just r , _ -> case r of
        Home -> 
          HH.slot_ (Proxy :: _ "home") unit Home.component unit
        Setting ->
          HH.slot_ (Proxy :: _ "setting") unit Setting.component {  ipfsInstanceType } 
        TopicList -> 
          HH.slot_ (Proxy :: _ "topicList") unit TopicList.component unit
        _ ->  HH.div_ [ HH.text "404" ]
      Nothing, _ ->
        HH.div_ [ HH.text "Oh yeah! You get a 404 page." ]
  ] 

type UseWindowWidth = UseState (Maybe Int) <> UseEffect <> Hooks.Pure

useWindowWidth
  :: forall m
   . MonadAff m
  => Hook m UseWindowWidth (Maybe Int)
useWindowWidth = Hooks.do
  width /\ widthId <- Hooks.useState Nothing -- [1]

  Hooks.useLifecycleEffect do -- [2]
    subscriptionId <- subscribeToWindow (Hooks.put widthId)
    pure $ Just $ Hooks.unsubscribe subscriptionId -- [3]

  Hooks.pure width -- [4]
  where
  -- we'll define the `subscribeToWindow` function in the next section, as it's
  -- ordinary effectful code and not Hooks specific.
  -- subscribeToWindow modifyWidth = ...
  subscribeToWindow :: ((Maybe Int) -> HookM m Unit)
    -- this is the same type variable `m` introduced by `useWindowWidth`
    -> HookM m H.SubscriptionId
  subscribeToWindow modifyWidth = do
    let
      readWidth :: Window -> HookM m Unit
      readWidth =
        modifyWidth <<< Just <=< liftEffect <<< Window.innerWidth

    window <- liftEffect window
    subscriptionId <- Hooks.subscribe do
      eventListener
        (Event.EventType "resize")
        (Window.toEventTarget window)
        (Event.target >=> Window.fromEventTarget >>> map readWidth)

    readWidth window
    pure subscriptionId

myComponent :: forall q i o m. MonadAff m => H.Component q i o m
myComponent = Hooks.component \_ _ -> Hooks.do
  width <- useWindowWidth -- our custom Hook
  Hooks.pure do
    HH.p_ [ HH.text $ "Window width is " <> maybe "" show width ]