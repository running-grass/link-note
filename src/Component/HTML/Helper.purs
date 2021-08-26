module LinkNote.Component.HTML.Helper where

import Prelude

import Halogen.HTML as HH
import Halogen.HTML.Properties (title)
import LinkNote.Component.HTML.Utils (css, icon)


helperHTML :: forall i p. HH.HTML i p
helperHTML = 
  HH.section
    [ 
      css "fixed bottom-8 right-8 cursor-pointer " 
      , title "Tab: 缩进  Shift-Tab: 反缩进  ⬆️/⬇️: 移动光标  Shift-⬆️/Shift-⬇️: 调整顺序"
    ]
    [  
      icon "help_outline"
    ]
