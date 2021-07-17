module App where


import Prelude

import Control.Monad.State (state)
import Data.Either (note)
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (logShow)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Orbitdb (getVal_, saveVal_)

type State
  = { note :: String }

data Action
  = Submit | SetNote String | InitNote

render :: forall cs m. State -> H.ComponentHTML Action cs m
render state =
  HH.div_
    [ 
      HH.div_ [ 
        HH.textarea 
          [ HP.placeholder "请在这里输入笔记内容！" 
            , HP.rows 5
            , HE.onValueInput \val -> SetNote val
            , HP.value state.note ]
          ]
    , HH.button [ HE.onClick \_ -> InitNote ] [ HH.text "加载" ]
    , HH.button [ HE.onClick \_ -> Submit ] [ HH.text "保存" ]

    ]

handleAction :: forall cs o m. MonadAff m => Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  SetNote note -> do
    H.modify_ _ { note = note }
  Submit -> do 
    note <- H.gets _.note
    logShow note
    H.liftEffect $ saveVal_ "note" note
  InitNote -> do
    n <- H.liftEffect $ getVal_ "note"
    logShow n
    H.modify_ _ { note = n }

initialState :: forall i. i -> State
initialState _ = { note: "" }

component :: forall q i o m. MonadAff m => H.Component q i o m
component =
  H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval { 
      handleAction = handleAction
      -- , initialize = Just InitNote
       }
    }

