module LinkNote.Component.Pomodoro where

import Prelude

import Data.Argonaut (JsonDecodeError(..), decodeJson, parseJson, stringify)
import Data.Argonaut.Encode.Class (encodeJson)
import Data.DateTime.Instant (unInstant)
import Data.Either (Either(..), note)
import Data.Formatter.Internal (repeat)
import Data.Int (floor, toNumber)
import Data.Maybe (Maybe(..))
import Data.String (length)
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.Hooks as Hooks
import LinkNote.Hooks.UseLocalStorage (useLocalStorage)
import LinkNote.Hooks.UseSecondTick (useSecondTick)
import Math (abs)

type PomodoroLog = {
  dur :: Int -- 番茄的时长
  , start :: Number -- 番茄开始时间
}
type Dur = {
  min :: Int
  , sec :: Int
}

showInt :: Int -> Int -> String
showInt len int = preand <> intStr
  where 
    intStr = show int 
    preand = repeat "0" $ if length intStr > len then 0 else len - length intStr
diff :: Number -> Number -> Dur
diff m1 m2 = { min, sec }
  where
    min = secs / 60
    sec = secs `mod` 60
    secs = floor $ ms / 1000.0
    ms = abs $ m1 - m2

component :: forall q i o m.  
  MonadAff m => 
  H.Component q i o m
component = Hooks.component \_ _ -> Hooks.do
  tick <- useSecondTick
  v /\ setV <- useLocalStorage "pomodoro-time"
  let p0 = (decodeJson =<< parseJson =<< note MissingValue v) :: Either JsonDecodeError PomodoroLog

  let sec = case tick of
              Nothing ->  0.0
              Just tick' -> case unInstant tick' of 
                Milliseconds ms' -> ms'

  let write _ = setV $ Just $ stringify (encodeJson { dur: 25, start: sec })
  case p0 of
    Left _ ->  Hooks.pure $ HH.p_ [
      HH.button [ HE.onClick \_ -> write unit ] [HH.text "🍅： ▶️"]
    ]
    Right p -> Hooks.pure do
        HH.p_ [ 
          HH.text $ "🍅： " <> durStr <> " "
          , HH.button [ HE.onClick \_ -> setV $ Nothing ] [HH.text "⏹️"]
          ]
      where
        durStr = showInt 2 durRec.min <> ":" <> showInt 2 durRec.sec
        durRec = diff (p.start + toNumber (p.dur * 60 * 1000)) sec 