module LinkNote.Hooks.UseLocalStorage where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested (type (/\), (/\))
import Effect.Aff.Class (class MonadAff)
import Halogen (liftEffect)
import Halogen.Hooks (type (<>), Hook, HookM, UseEffect, UseState)
import Halogen.Hooks as Hooks

import Web.HTML (window)
import Web.HTML.Window (localStorage)
import Web.Storage.Storage (getItem, removeItem, setItem)

type UseLocalStorage = UseState (Maybe String) <> UseEffect <> Hooks.Pure

useLocalStorage
  :: forall m
   . MonadAff m
  => String -> Hook m UseLocalStorage  ((Maybe String) /\ (Maybe String -> HookM m Unit))
useLocalStorage key = Hooks.do
  val /\ valId <- Hooks.useState Nothing

  let 
    lsE = localStorage =<< window
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
