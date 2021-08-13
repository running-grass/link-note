module LinkNote.Component.Store where

import Prelude
import Data.Maybe (Maybe(..))

data LogLevel = Dev | Prod

derive instance eqLogLevel :: Eq LogLevel
derive instance ordLogLevel :: Ord LogLevel

type Store =
  { 
      currentUser :: Maybe String
  }

data Action
  = LogoutUser 

-- | Finally, we'll map this action to a state update in a function called a
-- | 'reducer'. If you're curious to learn more, see the `halogen-store`
-- | documentation!
reduce :: Store -> Action -> Store
reduce store = case _ of
  LogoutUser -> store { currentUser = Nothing }
