module LinkNote.Component.Pomodoro
  (component) where

import Prelude

import Data.Argonaut (JsonDecodeError(..), decodeJson, parseJson, stringify)
import Data.Argonaut.Encode.Class (encodeJson)
import Data.DateTime.Instant (Instant, unInstant)
import Data.Either (Either(..), note)
import Data.Formatter.Internal (repeat)
import Data.Int (floor, toNumber)
import Data.Maybe (Maybe(..))
import Data.String (length)
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff.Class (class MonadAff, liftAff)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.Hooks (HookM, useTickEffect)
import Halogen.Hooks as Hooks
import LinkNote.Component.Notification as N
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

instantToNumber :: Instant -> Number
instantToNumber ins = unSeconds seconds
  where
    seconds = unInstant ins
    unSeconds (Milliseconds ms) = ms

showInt :: Int -> Int -> String
showInt len int = preand <> intStr
  where 
    intStr = show int 
    preand = repeat "0" $ if length intStr > len then 0 else len - length intStr

diff :: Number -> Number -> Dur
diff m1 m2 = { min
  , sec
  }
  where
    min = secs / 60
    sec = secs `mod` 60
    secs = floor $ ms / 1000.0
    ms = abs $ m1 - m2

component :: forall q i o m.  
  MonadAff m => 
  H.Component q i o m
component = Hooks.component \_ _ -> Hooks.do
  nowTickMB <- useSecondTick
  currentPomodoroStr /\ setPomodoroStr <- useLocalStorage "pomodoro-time"

  let 
    currentPomodoroEt :: Either JsonDecodeError PomodoroLog
    currentPomodoroEt = (decodeJson =<< parseJson =<< note MissingValue currentPomodoroStr)

    stop :: forall a . a -> HookM m Unit
    stop _ = do
      liftEffect $ N.notify "开始休息吧"
      setPomodoroStr $ Nothing
  
  Hooks.captures { nowTickMB } useTickEffect do
    case currentPomodoroEt, nowTickMB of
      Right pomodoro, Just nowTick 
        | (instantToNumber nowTick - pomodoro.start) / 60000.0 > toNumber pomodoro.dur -> stop unit
      _, _ -> pure unit
    pure Nothing

  case currentPomodoroEt , nowTickMB of
    Right p, Just nowTick -> do 
      Hooks.pure do
        HH.p_ [ 
          HH.text $ "🍅： " <> durStr <> " "
          , HH.button [ HE.onClick stop  ] [HH.text "⏹️"]
          ]
      where
        durStr = showInt 2 durRec.min <> ":" <> showInt 2 durRec.sec
        durRec = diff (p.start + toNumber (p.dur * 60 * 1000)) $ instantToNumber nowTick 
    _, Just nowTick ->  Hooks.pure $ HH.p_ [
      HH.button [ HE.onClick start ] [HH.text "🍅： ▶️"]
    ]
      where
        start :: forall a . a -> HookM m Unit
        start _ = do
          setPomodoroStr $ Just $ 
            stringify (encodeJson 
              { 
                dur: 25
                , start: instantToNumber nowTick
              })
          void $ liftAff $ N.requestPermission  -- 先请求一下弹窗权限
          liftEffect $ N.notify "开始新的番茄钟"
    _, _ -> Hooks.pure $ HH.span_ []