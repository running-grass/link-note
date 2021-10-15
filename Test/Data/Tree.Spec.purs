module LinkNote.Data.Tree.Spec where

import Prelude

import Data.Array as A
import Data.Array.NonEmpty as NEA
import Data.Foldable (foldl, foldr)
import Data.FoldableWithIndex (findWithIndex, foldlWithIndex, foldrWithIndex)
import Data.FunctorWithIndex (mapWithIndex)
import Data.Lens (preview, set, view)
import Data.Lens.Index (ix)
import Data.Maybe (Maybe(..))
import LinkNote.Data.Tree (Forest(..))
import LinkNote.Data.Tree as T
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

t :: forall a. a -> Array (T.Tree a) -> T.Tree a
t = T.mkNode
l :: forall a. a -> T.Tree a
l = T.leaf
f :: forall t3. Array (T.Tree t3) -> Forest t3
f = Forest

spec :: Spec Unit
spec =
  describe "测试Tree及Forest" do
    let tree1 = t 1 [t 2 [l 3, l 4], t 5 [l 6, l 7]] 
    let treeString = t "a" [ t "b" [l "c" , l "d" ], l "e"]
    let forest1 = Forest [treeString, treeString]
    let forest2 = Forest [tree1, tree1]
    let forest3 = Forest [tree1]
    let leaf1 = l "singleton"
    describe "测试Tree" do
      describe "测试Tree的ClassType" do
        it "测试Show" $ show leaf1 `shouldEqual` "<Tree \"singleton\" []>"
        it "测试Eq" $ (l "abcd" == l "abcd") `shouldEqual` true
        it "测试Ord" do
          (l "a" < l "b") `shouldEqual` true
          (l 2 < l 3) `shouldEqual` true
        it "测试functor" do
          map identity leaf1 `shouldEqual` leaf1
          map (\t' -> t' <> "test") leaf1 `shouldEqual` (l "singletontest")
        it "测试FunctorWithIndex" do
          mapWithIndex (\i _ -> i) leaf1 `shouldEqual` (l [])
          mapWithIndex (\i _ -> i) treeString `shouldEqual` t [] [ t [0] [l [0, 0] , l [0, 1] ], l [1]]
        it "测试foldable" do
          foldl (+) 0 tree1 `shouldEqual` 28
          foldr (+) 0 tree1 `shouldEqual` 28
          foldl (<>) "--" treeString `shouldEqual` "--abcde"
          foldr (<>) "--" treeString `shouldEqual` "abcde--"
      describe "测试Tree的相关函数" do
        it "测试fromFoldable" do 
          A.fromFoldable tree1 `shouldEqual` [1, 2, 3, 4, 5, 6, 7]
          A.fromFoldable treeString `shouldEqual` ["a", "b", "c", "d", "e"]
    describe "测试Forest" do
      it "测试functor" do
        map identity forest1 `shouldEqual` forest1
        map (\t' -> t' <> "test") forest1 `shouldEqual` Forest [t "atest" [ t "btest" [l "ctest" , l "dtest" ], l "etest"], t "atest" [ t "btest" [l "ctest" , l "dtest" ], l "etest"]]
      it "测试FunctorWithIndex" do
        mapWithIndex (\i _ -> i) forest1 `shouldEqual` 
          Forest [
            t (NEA.cons' 0 []) [ 
              t (NEA.cons' 0 [0]) [
                l (NEA.cons' 0 [0,0]) , 
                l (NEA.cons' 0 [0, 1])], 
              l (NEA.cons' 0 [1])],   
            t (NEA.cons' 1 []) [ 
              t (NEA.cons' 1 [0]) [
                l (NEA.cons' 1 [0,0]) , 
                l (NEA.cons' 1 [0, 1])], 
              l (NEA.cons' 1 [1])]
          ]
        T.modify (const 110) (NEA.cons' 0 [0, 0]) forest3 `shouldEqual` Forest [t 1 [t 2 [l 110, l 4], t 5 [l 6, l 7]] ]
      it "测试foldable" do
        foldl (+) 0 forest2 `shouldEqual` 56
        foldr (+) 0 forest2 `shouldEqual` 56
        foldl (<>) "--" forest1 `shouldEqual` "--abcdeabcde"
        foldr (<>) "--" forest1 `shouldEqual` "abcdeabcde--"
      it "测试FoldableWithIndex" do
        foldlWithIndex (\_ x acc -> x + acc) 0 forest2 `shouldEqual` 56
        foldrWithIndex (\_ x acc -> x + acc) 0 forest2 `shouldEqual` 56
        -- foldlWithIndex (\i x acc -> x <> acc) "--" forest1 `shouldEqual` "--abcdeabcde"
        foldrWithIndex (\_ x acc -> x <> acc) "--" forest1 `shouldEqual` "abcdeabcde--"
        findWithIndex (\_ n -> n == "d") forest1 `shouldEqual` Just {index : NEA.cons' 0 [0, 1], value: "d"}
          -- TODO idx
      it "测试look" do
        T.look' forest1 (NEA.cons' 1 [0, 1]) `shouldEqual` Just "d"
      it "测试findSubTree" do
        T.findSubTree (\n -> n == "b") treeString `shouldEqual` Just (t "b" [l "c" , l "d" ])
        T.findTree (\n -> n == "b") forest1 `shouldEqual` Just (t "b" [l "c" , l "d" ])        
        T.findChildrenByTree (\n -> n == "b") forest1 `shouldEqual` Just ["c", "d"]
      it "测试insertSubTree" do
        T.insertSubTree (NEA.cons' 0 []) (l "c") (Forest [l "a"]) `shouldEqual` Just (Forest [l "c", l "a"])        
        T.insertSubTree (NEA.cons' 0 [1,2]) (l "c") (Forest [l "a"]) `shouldEqual` Nothing
        T.insertSubTree (NEA.cons' 3 []) (l "c") (Forest [l "a"]) `shouldEqual` Nothing
        T.insertSubTree (NEA.cons' 0 [1,0]) (l 120) forest3 `shouldEqual` Just (Forest [t 1 [t 2 [l 3, l 4], t 5 [l 120, l 6, l 7]] ])
        T.insertSubTree (NEA.cons' 0 [1,3]) (l 120) forest3 `shouldEqual` Nothing
        T.insertSubTree (NEA.cons' 0 [1,2]) (l 120) forest3 `shouldEqual` Just (Forest [t 1 [t 2 [l 3, l 4], t 5 [l 6, l 7, l 120]] ])
      it "deleteAt" do
        T.deleteAt (NEA.cons' 0 [])  (Forest [l "a"]) `shouldEqual` Just (Forest [])        
        T.deleteAt (NEA.cons' 0 [1,2]) (Forest [l "a"]) `shouldEqual` Nothing        
        T.deleteAt (NEA.cons' 3 [])  (Forest [l "a"]) `shouldEqual` Nothing
        T.deleteAt (NEA.cons' 0 [1,0])  forest3 `shouldEqual` Just (Forest [t 1 [t 2 [l 3, l 4], t 5 [l 7]] ])
        T.deleteAt (NEA.cons' 0 [1,3])  forest3 `shouldEqual` Nothing
        T.deleteAt (NEA.cons' 0 [1,2])  forest3 `shouldEqual` Nothing
      it "moveSubTree" do
        T.moveSubTree (NEA.cons' 0 []) (NEA.cons' 0 []) forest3 `shouldEqual` Just forest3
        -- 非法移动路径
        T.moveSubTree (NEA.cons' 0 []) (NEA.cons' 0 [1,1]) forest3 `shouldEqual` Nothing
        T.moveSubTree (NEA.cons' 0 [1, 1]) (NEA.cons' 0 []) forest3 `shouldEqual` Just (f [l 7, t 1 [t 2 [l 3, l 4], t 5 [l 6]] ])
      it "测试lens" do
        view T._data tree1 `shouldEqual` 1
        view T._subTrees tree1 `shouldEqual` [t 2 [l 3, l 4], t 5 [l 6, l 7]] 
        set T._data 9 tree1 `shouldEqual` t 9 [t 2 [l 3, l 4], t 5 [l 6, l 7]]
        set T._subTrees [] tree1 `shouldEqual` t 1 []

        let _p = (ix (NEA.cons' 0 [0]))
        preview _p forest3 `shouldEqual` Just 2
        set _p 9 forest3 `shouldEqual` f [t 1 [t 9 [l 3, l 4], t 5 [l 6, l 7]] ]