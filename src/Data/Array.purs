module LinkNote.Data.Array where

import Prelude

import Data.Array (uncons)
import Data.Array as A
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

modifyAtLast :: forall a . (a -> a) -> NonEmptyArray a -> NonEmptyArray a
modifyAtLast f ax = case NA.unsnoc ax of
    { init: ax' , last: x } -> NA.snoc' ax' $ f x

modifyAtHead :: forall a . (a -> a) -> NonEmptyArray a -> NonEmptyArray a
modifyAtHead f ax = case NA.uncons ax of
    { head: x , tail: ax' } -> NA.cons' (f x) ax'

modifyAtLastArray :: forall a . (a -> a) -> Array a -> Maybe (Array a)
modifyAtLastArray f as = A.modifyAt (A.length as - 1) f as

modifyAtHeadArray :: forall a . (a -> a) -> Array a -> Maybe (Array a)
modifyAtHeadArray = A.modifyAt 0