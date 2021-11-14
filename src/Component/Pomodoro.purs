module LinkNote.Component.Pomodoro
  (component) where

import Prelude

import Data.Argonaut (class DecodeJson, class EncodeJson, JsonDecodeError(..), decodeJson, parseJson, stringify)
import Data.Argonaut.Decode.Generic (genericDecodeJson)
import Data.Argonaut.Encode.Class (encodeJson)
import Data.Argonaut.Encode.Generic (genericEncodeJson)
import Data.DateTime.Instant (Instant, unInstant)
import Data.Either (Either(..), note)
import Data.Formatter.Internal (repeat)
import Data.Generic.Rep (class Generic)
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
import LinkNote.Hooks.UseSecondTick (useSecondTick)
import LinkNote.Hooks.UseSessionStorage (useSessionStorage)
import Math (abs)

data Status = Unset 
            | Timeing Number
            | ShortBreaking Number
            | LongBreaking Number -- 未开始、专注中、休息中

type CurrentStatus = {
  status :: Status
  , breakCount :: Int
}

derive instance Generic Status _
instance EncodeJson Status where
  encodeJson = genericEncodeJson

instance DecodeJson Status where
  decodeJson = genericDecodeJson

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

type Input = {
  timer :: Int
  , shortBreak :: Int 
}

component :: forall q o m.  
  MonadAff m => 
  H.Component q Input o m
component = Hooks.component \_ input -> Hooks.do
  nowTickMB <- useSecondTick
  statusStr /\ setStatusStr <- useSessionStorage "pomodoro-time"
  let 
    statusEither :: Either JsonDecodeError CurrentStatus
    statusEither = (decodeJson =<< parseJson =<< note MissingValue statusStr)

    setStatus :: CurrentStatus -> HookM m Unit
    setStatus = setStatusStr <<< Just <<< stringify <<< encodeJson

    stop :: forall a . a -> HookM m Unit
    stop _ = do
      liftEffect $ N.notify "停止吧"
      setStatus { status: Unset, breakCount: 0 }
    breakFinish breakCount = do
      liftEffect $ N.notify "完成一个休息"
      setStatus { status: Unset, breakCount }

    break :: Number -> Int -> HookM m Unit
    break start count = do
      liftEffect $ N.notify "开始休息吧"
      setStatus { status: ShortBreaking start, breakCount: count }

    -- start :: forall a . a -> HookM m Unit
    startPdmr nowTick breakCount = do
      setStatus { status:  Timeing nowTick, breakCount }
      void $ liftAff $ N.requestPermission  -- 先请求一下弹窗权限
      liftEffect $ N.notify "开始新的番茄钟"
  Hooks.captures { nowTickMB } useTickEffect do
    case statusEither, nowTickMB of
      Right { status : Timeing start, breakCount }, Just nowTick 
        | (instantToNumber nowTick - start) / 60000.0 > toNumber input.timer -> break (instantToNumber nowTick) (breakCount + 1)
      Right { status : ShortBreaking start, breakCount }, Just nowTick 
        | (instantToNumber nowTick - start) / 60000.0 > toNumber input.shortBreak -> breakFinish (breakCount)
      _, _ -> pure unit
    pure Nothing

  case statusEither , nowTickMB of
    Right { status : Timeing start }, Just nowTick -> do
      Hooks.pure do
        HH.p_ [ 
          HH.text $ "🍅： " <> durStr <> " "
          , HH.button [ HE.onClick stop  ] [HH.text "⏹️"]
          ]
      where
        durStr = showInt 2 durRec.min <> ":" <> showInt 2 durRec.sec
        durRec = diff (start + toNumber (input.timer * 60 * 1000)) $ instantToNumber nowTick
    Right { status: ShortBreaking start, breakCount }, Just nowTick -> do
      Hooks.pure do
        HH.p_ [ 
          HH.text $ "🍅休息中……： " <> durStr <> " "
          , HH.button [ HE.onClick \_ -> startPdmr (instantToNumber nowTick) (breakCount) ] [HH.text "▶️"]
          ]
      where
        durStr = showInt 2 durRec.min <> ":" <> showInt 2 durRec.sec
        durRec = diff (start + toNumber (input.shortBreak * 60 * 1000)) $ instantToNumber nowTick
    Right { status: Unset, breakCount }, Just nowTick ->  Hooks.pure $ HH.p_ [
      HH.button [ HE.onClick \_ -> startPdmr (instantToNumber nowTick) breakCount ] [HH.text "🍅： ▶️"]
    ]
    _, Just nowTick ->  Hooks.pure $ HH.p_ [
      HH.button [ HE.onClick \_ -> startPdmr (instantToNumber nowTick) 0 ] [HH.text "🍅： ▶️"]
    ]
    _, _ -> Hooks.pure $ HH.span_ []