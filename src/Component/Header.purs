module LinkNote.Component.Header where

import Prelude

import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML (slot_)
import Halogen.HTML as HH
import LinkNote.Component.HTML.Utils (css, safeHref)
import LinkNote.Component.Pomodoro as Pomodoro
import LinkNote.Data.Route (Route(..))
import Type.Proxy (Proxy(..))

type OpaqueSlot slot = forall query. H.Slot query Void slot

type Input = {
    route :: Route
} 

type State = { 
    route :: Route
}

type ChildSlots =
  ( pomodoro :: OpaqueSlot Unit
  )

initialState :: Input -> State
initialState input = { 
  route: input.route
}

component :: forall q m. MonadAff m
  => H.Component q Input Void m
component = H.mkComponent
  { 
    initialState
  , render
  , eval: H.mkEval $ H.defaultEval
  }
  where
  render :: State -> H.ComponentHTML Unit ChildSlots m
  render { route } = HH.nav
    [ css "mb-4 px-2 bg-gray-200 rounded" ]
    [  HH.ul
        [ css "flex space-x-4" ] 
        [ navItem Home  [ HH.text "首页" ] $ isActiveRoute Home
        , navItem TopicList  [ HH.text "主题" ] $ isActiveRoute TopicList
        , navItem Setting  [ HH.text "设置" ] $ isActiveRoute Setting
        , slot_ (Proxy :: _ "pomodoro") unit Pomodoro.component { timer: 25, shortBreak: 5 }
        ]
    ]
      where
      navItem r html isActive=
          HH.li
          [ css $ "nav-item" <> if isActive then " text-blue-500" else ""]
          [ HH.a
              [ css "nav-link"  -- <> guard (route == r) " active"
              , safeHref r
              ]
              html
          ]
      isActiveRoute routeItem = route == routeItem