module LinkNote.Page.Home where

import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Prelude (Unit)

type Input = Unit

type State = { 
}

data Action = Submit

render :: forall cs m. State -> H.ComponentHTML Action cs m
render _ =
  HH.section_ [
    HH.h3_ [HH.text "快捷键"]
    , HH.h4_ [HH.text "笔记编辑状态下"]
    , HH.ul_ [
      HH.li_ [HH.text "Enter: 新建同级笔记"]
      , HH.li_ [HH.text "Tab: 缩进"]
      , HH.li_ [HH.text "Shift-Tab: 反缩进"]
      , HH.li_ [HH.text " ⬆️/⬇️: 移动光标 "]
      , HH.li_ [HH.text "Shift-⬆️/Shift-⬇️: 调整顺序"]
    ]
    , HH.br_
    , HH.h4_ [ HH.text "快捷提示弹窗状态下"]
    , HH.ul_ [
      HH.li_ [HH.text "Enter: 应用选中的条目 "]
      , HH.li_ [HH.text " ⬆️/⬇️: 移动光标"]
    ]
  ]

initialState :: Input-> State
initialState _ = { }

component :: forall q  o m. MonadAff m => H.Component q Input o m
component =
  H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval 
    }
