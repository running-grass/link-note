-- | This module exports a pure HTML function to render a consistent header throughout the app.
module LinkNote.Component.HTML.Header where
import Prelude
import Data.Maybe (Maybe(..))

import Halogen.HTML as HH
import LinkNote.Component.HTML.Utils (css, safeHref)
import LinkNote.Data.Route (Route(..))


header :: forall i p. Maybe Route -> HH.HTML i p
header routeMaybe =
  HH.nav
    [ css "mb-4 px-2 bg-gray-200 rounded" ]
    [  HH.ul
        [ css "flex space-x-4" ]
        [ navItem Home  [ HH.text "首页" ] $ isActiveRoute Home
        , navItem TopicList  [ HH.text "主题" ] $ isActiveRoute TopicList
        , navItem Setting  [ HH.text "设置" ] $ isActiveRoute Setting
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
  isActiveRoute route = case routeMaybe of 
    Nothing -> false
    Just route' -> route == route'
