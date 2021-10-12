module LinkNote.Data.Tree where

import Prelude

import Data.Array as A
import Data.Array.NonEmpty as NEA
import Data.Foldable (class Foldable, foldMapDefaultR, foldl, foldr)
import Data.FoldableWithIndex (class FoldableWithIndex, foldMapWithIndexDefaultR)
import Data.FoldableWithIndex as FoldableWithIndex
import Data.FunctorWithIndex (class FunctorWithIndex, mapWithIndex)
import Data.Maybe (Maybe(..))
import Prim.TypeError (class Warn, Text)

type TreeIndexPath = Array Int
type ForestIndexPath = NEA.NonEmptyArray Int

data Tree a = Node a (Forest a)
derive instance Eq a => Eq (Tree a)
derive instance Ord a => Ord (Tree a)
instance Functor Tree where
  map f (Node a (Forest as)) = Node (f a) (Forest $ map (map f) as)

instance FunctorWithIndex TreeIndexPath Tree where
  mapWithIndex :: forall a b . (TreeIndexPath → a → b) → Tree a → Tree b 
  mapWithIndex f ta = innerMap [] ta
    where
      innerMap currIdx (Node x (Forest xs)) = Node (f currIdx x) (Forest $ mapWithIndex (\i ta' -> innerMap (A.snoc currIdx i) ta') xs)

instance Foldable Tree where
  foldMap = foldMapDefaultR
  foldr f acc (Node a (Forest as)) = f a (foldr (flip (foldr f)) acc as)
  foldl f acc (Node a (Forest as)) = foldl (foldl f) (f acc a) as

instance Show a => Show (Tree a) where
  show (Node node forest) = "<Tree " <> show node <> " " <> show forest <> ">"


--------------------------  Forest ------------------------------
newtype Forest a = Forest (Array (Tree a))
derive newtype instance Eq a => Eq (Forest a)
derive newtype instance Ord a => Ord (Forest a)
derive instance Functor Forest
instance FunctorWithIndex ForestIndexPath Forest where 
    mapWithIndex :: forall a b . (ForestIndexPath → a → b) → Forest a → Forest b 
    mapWithIndex f (Forest trees) = Forest $ mapWithIndex (\idx tree -> innerMap (NEA.singleton idx) tree) trees
        where 
            innerMap currIdx (Node a (Forest xs)) = 
                Node (f currIdx a) (Forest $ mapWithIndex 
                                    (\i ta' -> innerMap (NEA.snoc currIdx i) ta') 
                                    xs)
instance Foldable Forest where
  foldMap = foldMapDefaultR
  foldr f acc (Forest fs) = foldr (flip (foldr f)) acc fs
  foldl f acc (Forest fs) = foldl (foldl f) acc fs
  
instance FoldableWithIndex ForestIndexPath Forest where
  foldMapWithIndex = foldMapWithIndexDefaultR
  foldrWithIndex :: forall a b. (ForestIndexPath -> a -> b -> b) -> b -> Forest a -> b
  foldrWithIndex f ac fa = innerFold [] ac fa
    where 
      innerFold currIdx acc (Forest trees) = FoldableWithIndex.foldrWithIndex (\i (Node x fs') acc' -> f (NEA.snoc' currIdx i) x (innerFold (A.snoc currIdx i) acc' fs') ) acc trees
  foldlWithIndex :: forall a b. Warn (Text "`FoldableWithIndex ForestIndexPath Forest` 逻辑有问题，顺序不对。") => (ForestIndexPath -> b -> a -> b) -> b -> Forest a -> b
  foldlWithIndex f ac fa = innerFold [] ac fa 
    where 
      innerFold currIdx acc (Forest trees) = FoldableWithIndex.foldlWithIndex (\i acc' (Node x fs') -> f (NEA.snoc' currIdx i) (innerFold (A.snoc currIdx i) acc' fs') x) acc trees
   
instance Show a => Show (Forest a) where
  show (Forest forest) = show forest

----------------------------------------------

emptyForest :: forall a . Forest a
emptyForest = Forest []

leaf :: forall a. a -> Tree a
leaf x = Node x emptyForest

mkNode :: forall a. a -> Array (Tree a) -> Tree a
mkNode x xs = Node x $ Forest xs

getData :: forall a. Tree a -> a
getData (Node x _) = x

getChildrenData :: forall a. Tree a -> Array a
getChildrenData (Node _ (Forest xs)) = xs <#> getData

modify :: forall a. (a -> a) -> ForestIndexPath -> Forest a -> Forest a
modify f path fa = mapWithIndex (\i x -> if i == path then f x else x) fa

look' :: forall a. Forest a -> ForestIndexPath -> Maybe a
look' fs xs = look fs xs <#> getData

look :: forall a. Forest a -> ForestIndexPath -> Maybe (Tree a)
look (Forest trees) xs = case pathLen, currNode, restPath of
  1, _, _ -> currNode
  _, Just (Node _ forest'), Just xs' -> look forest' xs'
  _, _, _ -> Nothing
  where
    currIdx = NEA.head xs
    pathLen = NEA.length xs
    currNode = A.index trees currIdx
    restPath = NEA.fromArray (NEA.tail xs)

findTree :: forall a. (a -> Boolean) -> Forest a -> Maybe (Tree a)
findTree p (Forest trees) = foldr go Nothing trees
  where
  go ta@(Node x (Forest fs)) Nothing | p x = Just ta
                                     | otherwise = foldr go Nothing fs
  go _ r = r

findSubTree :: forall a. (a -> Boolean) -> Tree a -> Maybe (Tree a)
findSubTree p ta@(Node x forest)  | p x = Just ta
                                  | otherwise = findTree p forest

findChildrenByTree :: forall a. (a -> Boolean) -> Forest a -> Maybe (Array a)
findChildrenByTree p fa = case findTree p fa of
  (Just (Node _ (Forest as))) -> Just $ as <#> getData
  _ -> Nothing

childrenLenth :: forall a. Tree a -> Int
childrenLenth (Node _ (Forest xs)) = A.length xs

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