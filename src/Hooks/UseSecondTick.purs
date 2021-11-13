module LinkNote.Hooks.UseSecondTick where

import Prelude

import Control.Monad.Rec.Class (forever)
import Data.DateTime.Instant (Instant)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff as Aff
import Effect.Aff.Class (class MonadAff)
import Effect.Now as EffNow
import Halogen (liftEffect)
import Halogen as H
import Halogen.Hooks (type (<>), Hook, HookM, UseEffect, UseState)
import Halogen.Hooks as Hooks
import Halogen.Subscription (Emitter)
import Halogen.Subscription as HS


type UseSecondTick = UseState (Maybe Instant) <> UseEffect <> Hooks.Pure

useSecondTick
  :: forall m
   . MonadAff m
  => Hook m UseSecondTick (Maybe Instant)
useSecondTick = Hooks.do
  tStr /\ tId <- Hooks.useState Nothing -- [1]
  Hooks.useLifecycleEffect do -- [2]
    subscriptionId <- subscribeToTimer (Hooks.put tId)
    pure $ Just $ Hooks.unsubscribe subscriptionId -- [3]

  Hooks.pure tStr -- [4]
  where
    subscribeToTimer :: ((Maybe Instant) -> HookM m Unit) -> HookM m H.SubscriptionId
    subscribeToTimer putTime = do

      let 
        putTime' :: forall a . a -> HookM m Unit
        putTime' =  putTime <<< Just <=< liftEffect <<< (const EffNow.now)
      t :: Emitter (HookM m Unit) <- timer (putTime' unit)
      subscriptionId <- Hooks.subscribe t
      pure subscriptionId

      where 
        timer :: forall m2 a. MonadAff m2 => a -> m2 (HS.Emitter a)
        timer val = do
          { emitter, listener } <- H.liftEffect HS.create
          _ <- H.liftAff $ Aff.forkAff $ forever do
            Aff.delay $ Milliseconds 1000.0
            H.liftEffect $ HS.notify listener val
          pure emitter