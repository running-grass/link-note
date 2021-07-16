module App where


import Prelude

import Halogen as H
import Halogen.HTML as HH

import Halogen.HTML.Properties as HP

type State
  = { count :: Int }

data Action
  = Increment

render :: forall state cs m. state -> H.ComponentHTML Action cs m
render _ =
  HH.div_
    [ 
      HH.div_ [ HH.textarea [ HP.placeholder "请在这里输入笔记内容！" , HP.rows 2 ]]
    , HH.button_ [ HH.text "保存" ]
    ]

handleAction :: forall cs o m. Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  Increment -> H.modify_ \st -> st { count = st.count + 1 }


component :: forall q i o m. H.Component q i o m
component =
  H.mkComponent
    { initialState: \_ -> { count: 0 }
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }