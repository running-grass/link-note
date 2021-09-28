module LinkNote.Data.Tree where

import Prelude

import Data.Array as A
import Data.Array.NonEmpty as NEA
import Data.Foldable (class Foldable, foldMapDefaultR, foldl, foldr)
import Data.FunctorWithIndex (class FunctorWithIndex, mapWithIndex)
import Data.Maybe (Maybe(..))

type TreeIndexPath = Array Int
type ForestIndexPath = NEA.NonEmptyArray Int

data Tree a = Node a (Array (Tree a))
derive instance Eq a => Eq (Tree a)
derive instance Ord a => Ord (Tree a)
instance Functor Tree where
  map f (Node a rests) = Node (f a) (map (map f) rests)

instance FunctorWithIndex TreeIndexPath Tree where
  mapWithIndex :: forall a b . (TreeIndexPath → a → b) → Tree a → Tree b 
  mapWithIndex f ta = innerMap [] ta
    where 
        innerMap currIdx (Node a forest) = 
            Node (f currIdx a) (mapWithIndex 
                                (\i ta' -> innerMap (A.snoc currIdx i) ta') 
                                forest)

instance Foldable Tree where
  foldMap = foldMapDefaultR
  foldr f acc (Node a rest) = f a (foldr (flip (foldr f)) acc rest)
  foldl f acc (Node a rest) = foldl (foldl f) (f acc a) rest

instance Show a => Show (Tree a) where
  show (Node node forest) = "<Tree " <> show node <> " " <> show forest <> ">"

newtype Forest a = Forest (Array (Tree a))
derive newtype instance Eq a => Eq (Forest a)
derive newtype instance Ord a => Ord (Forest a)
derive instance Functor Forest
instance FunctorWithIndex ForestIndexPath Forest where 
    mapWithIndex :: forall a b . (ForestIndexPath → a → b) → Forest a → Forest b 
    mapWithIndex f (Forest trees) = Forest $ mapWithIndex (\idx tree -> innerMap (NEA.singleton idx) tree) trees
        where 
            innerMap currIdx (Node a forest) = 
                Node (f currIdx a) (mapWithIndex 
                                    (\i ta' -> innerMap (NEA.snoc currIdx i) ta') 
                                    forest)
instance Show a => Show (Forest a) where
  show (Forest forest) = show forest

emptyForest :: forall a . Forest a
emptyForest = Forest []

leaf :: forall a. a -> Tree a
leaf x = Node x []

-- look 可以使用foldable+maybe来实现
-- look :: forall a. Forest a -> ForestIndexPath -> Maybe a
-- look nodes path = do
--   let us = NEA.uncons path
--   current@(NoteNode curr) <- NEA.index nodes us.head 
--   if null us.tail 
--     then pure current
--     else do
--       tail <- fromArray us.tail
--       look curr.children tail


-- findNode :: NoteId -> Array NoteNode -> Maybe NoteNode
-- findNode id nodes = Array.find (\(NoteNode n) -> n.id == id) $ flatten nodes

parentPath :: ForestIndexPath -> Maybe ForestIndexPath
parentPath path = do
  let len = NEA.length path
  if len == 1 
    then Nothing
    else NEA.fromArray $ NEA.init path

prevPath :: ForestIndexPath -> Maybe ForestIndexPath
prevPath path = do
  let las = NEA.last path
  let lasInx = (NEA.length path) - 1
  if las == 0 
    then Nothing
    else NEA.updateAt lasInx (las - 1) path