module LinkNote.Hooks.UseSessionStorage where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested (type (/\), (/\))
import Effect.Aff.Class (class MonadAff)
import Halogen (liftEffect)
import Halogen.Hooks (type (<>), Hook, HookM, UseEffect, UseState)
import Halogen.Hooks as Hooks
import Web.HTML (window)
import Web.HTML.Window (sessionStorage)
import Web.Storage.Storage (getItem, removeItem, setItem)

type UseSessionStorage = UseState (Maybe String) <> UseEffect <> Hooks.Pure

useSessionStorage
  :: forall m
   . MonadAff m
  => String -> Hook m UseSessionStorage  ((Maybe String) /\ (Maybe String -> HookM m Unit))
useSessionStorage key = Hooks.do
  val /\ valId <- Hooks.useState Nothing

  let 
    lsE = sessionStorage =<< window
    setVal :: Maybe String -> HookM m Unit
    setVal newVal = do 
      ls <- liftEffect lsE
      -- liftEffect $ logAnyE newVal
      liftEffect $ case newVal of
        Just v -> setItem key v ls
        Nothing -> removeItem key ls
          
      Hooks.put valId newVal
  Hooks.useLifecycleEffect do
    ls <- liftEffect lsE
    mStr <- liftEffect $ getItem key ls
    Hooks.put valId mStr
    pure Nothing

  Hooks.pure $ val /\ setVal
