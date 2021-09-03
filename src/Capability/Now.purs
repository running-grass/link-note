-- | A capability representing the ability to fetch the current time. This is pure, so we can
-- | use fixed times in a test monad for determinism.
-- |
-- | To learn more about why we use capabilities and this architecture, please see the guide:
-- | https://thomashoneyman.com/guides/real-world-halogen/push-effects-to-the-edges/
module LinkNote.Capability.Now where

import Prelude

import Control.Monad.Trans.Class (lift)
import Data.DateTime (Date, DateTime, Time)
import Data.DateTime.Instant (Instant)
import Halogen (HalogenM)

class Monad m <= Now m where
  now :: m Instant
  nowDate :: m Date
  nowTime :: m Time
  nowDateTime :: m DateTime

-- | This instance lets us avoid having to use `lift` when we use these functions in a component.
instance nowHalogenM :: Now m => Now (HalogenM st act slots msg m) where
  now = lift now
  nowDate = lift nowDate
  nowTime = lift nowTime
  nowDateTime = lift nowDateTime
