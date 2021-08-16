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
    HH.text "请切换到主题页面使用"
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
