module LinkNote.Component.Pomodoro where

import Prelude

import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple.Nested ((/\))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.Hooks as Hooks
import LinkNote.Hooks.UseLocalStorage (useLocalStorage)
import LinkNote.Hooks.UseSecondTick (useSecondTick)


component :: forall q i o m. MonadAff m => H.Component q i o m
component = Hooks.component \_ _ -> Hooks.do
  tick <- useSecondTick
  v /\ setV <- useLocalStorage "pomodoro-time"
  Hooks.pure do
    HH.p_ [ 
      HH.text $ "当前的时间为" <> fromMaybe "" tick <> ";之前的时间点" <> fromMaybe "" v
      , HH.button [ HE.onClick \_ -> setV $ Nothing ] [HH.text "清空时间"]
      , HH.button [ HE.onClick \_ -> setV  tick ] [HH.text "设置当前时间"]
      ]
