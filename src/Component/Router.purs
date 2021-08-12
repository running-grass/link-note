module LinkNote.Component.Router where


import Prelude

import Data.Either (hush)
import Data.Maybe (Maybe(..), fromMaybe)
import Effect.Aff.Class (class MonadAff)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import IPFS (IPFS)
import LinkNote.Component.Navigate (class Navigate, navigate)
import LinkNote.Data.Route (Route(..), routeCodec)
import LinkNote.Page.Home (Note, File)
import LinkNote.Page.Home as Home
import Routing.Duplex as RD
import Routing.Hash (getHash)
import RxDB.Type (RxCollection)
import Type.Proxy (Proxy(..))

type OpaqueSlot slot = forall query. H.Slot query Void slot

data Query a
  = Navigate Route a

type State = { 
    route :: Maybe Route,
    coll :: RxCollection Note, 
    collFile :: RxCollection File,
    ipfs :: IPFS 
  }

type Input = { 
  coll :: RxCollection Note, 
  collFile :: RxCollection File,
  ipfs :: IPFS 
  }

data Action
  = Init

type ChildSlots =
  ( home :: OpaqueSlot Unit
  , setting :: OpaqueSlot Unit
  )

initialState :: Input -> State
initialState input = { 
  route: Nothing,
  coll : input.coll,
  collFile : input.collFile,
  ipfs : input.ipfs
  }

component
  :: forall m
   . MonadAff m
  => Navigate m
  => H.Component Query Input Void m
component = H.mkComponent
  { initialState: initialState
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
      -- first we'll get the route the user landed on
      initialRoute <- hush <<< (RD.parse routeCodec) <$> liftEffect getHash
      -- then we'll navigate to the new route (also setting the hash)
      H.modify_ _ { route = initialRoute }
      navigate $ fromMaybe Home initialRoute
      -- navigate Home

  handleQuery :: forall a. Query a -> H.HalogenM State Action ChildSlots Void m (Maybe a)
  handleQuery = case _ of
    Navigate dest a -> do
      { route } <-  H.get
      -- don't re-render unnecessarily if the route is unchanged
      when (route /= Just dest) do 
        H.modify_ _ { route = Just dest }
      pure (Just a)

  render :: State -> H.ComponentHTML Action ChildSlots m
  render { route, ipfs, coll, collFile  } = case route of
    Just r -> case r of
      Home ->
        HH.slot_ (Proxy :: _ "home") unit Home.component {ipfs, coll, collFile}
      Setting -> HH.div_ [ HH.text "I will be a setting page." ]
        -- HH.slot_ (Proxy :: _ "setting") unit Home.component {ipfs, coll, collFile}
      -- _ -> HH.div_ [ HH.text "error route" ]
    Nothing ->
      HH.div_ [ HH.text "Oh yeah! You get a 404 page." ]
