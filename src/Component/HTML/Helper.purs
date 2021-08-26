module LinkNote.Component.HTML.Helper where

import Prelude

import Halogen.HTML as HH
import LinkNote.Component.HTML.Utils (css, icon)


helperHTML :: forall i p. HH.HTML i p
helperHTML  =
  HH.section
    [ css "fixed bottom-8 right-8 cursor-pointer " ]
    [  
      icon "help_outline"
    ]
