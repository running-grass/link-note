-- | This module exports a pure HTML function to render a consistent header throughout the app.
module LinkNote.Component.HTML.Header where

import Halogen.HTML as HH
import Halogen.HTML.Properties (style)
import LinkNote.Component.HTML.Utils (css, safeHref)
import LinkNote.Data.Route (Route(..))

header :: forall i p. HH.HTML i p
header =
  HH.nav
    [ css "mb-4" ]
    [ HH.div
        [  ]
        [  HH.ul
            [ css "flex space-x-4" ]
            [ navItem Home  [ HH.text "首页" ]
            , navItem Setting  [ HH.text "设置" ]
            ]
        ]
    ]

  where
  navItem r html =
    HH.li
      [ css "nav-item" ]
      [ HH.a
          [ css "nav-link"  -- <> guard (route == r) " active"
          , safeHref r
          ]
          html
      ]
