module LinkNote.Data.Array where

import Prelude

import Data.Array (uncons)
import Data.Array.NonEmpty (NonEmptyArray)
import Data.Array.NonEmpty as NA
import Data.Maybe (Maybe(..))

startsWith :: forall a . Eq a => Array a -> Array a -> Boolean
startsWith xs ys = case uncons xs, uncons ys of 
    Nothing , _ -> true
    Just _ , Nothing -> false
    Just { head: x, tail: xs' }, Just { head: y, tail: ys'} -> if x /= y then false else startsWith xs' ys'

startsWithNonEmptyArray :: forall a. Eq a => NonEmptyArray a -> NonEmptyArray a -> Boolean
startsWithNonEmptyArray xs ys = startsWith xs' ys'
    where
      xs' = NA.toArray xs
      ys' = NA.toArray ys