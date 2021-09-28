module LinkNote.Test.Data.Tree.Spec where

import Prelude

import Data.Array as A
import Data.Array.NonEmpty as NEA
import Data.Foldable (foldl, foldr)
import Data.FunctorWithIndex (mapWithIndex)
import LinkNote.Data.Tree (Forest(..))
import LinkNote.Data.Tree as T
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec =
  describe "测试Tree及Forest" do
    let tree1 = T.Node 1 [T.Node 2 [T.leaf 3, T.leaf 4], T.Node 5 [T.leaf 6, T.leaf 7]] 
    let treeString = T.Node "a" [ T.Node "b" [T.leaf "c" , T.leaf "d" ], T.leaf "e"]
    let forest1 = Forest [treeString, treeString]
    let leaf1 = T.leaf "singleton"
    describe "测试Tree" do
      describe "测试Tree的ClassType" do
        it "测试Show" $ show leaf1 `shouldEqual` "<Tree \"singleton\" []>"
        it "测试Eq" $ (T.leaf "abcd" == T.leaf "abcd") `shouldEqual` true
        it "测试Ord" do
          (T.leaf "a" < T.leaf "b") `shouldEqual` true
          (T.leaf 2 < T.leaf 3) `shouldEqual` true
        it "测试functor" do
          map identity leaf1 `shouldEqual` leaf1
          map (\t -> t <> "test") leaf1 `shouldEqual` (T.leaf "singletontest")
        it "测试FunctorWithIndex" do
          mapWithIndex (\i _ -> i) leaf1 `shouldEqual` (T.leaf [])
          mapWithIndex (\i _ -> i) treeString `shouldEqual` T.Node [] [ T.Node [0] [T.leaf [0, 0] , T.leaf [0, 1] ], T.leaf [1]]
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
        map (\t -> t <> "test") forest1 `shouldEqual` Forest [T.Node "atest" [ T.Node "btest" [T.leaf "ctest" , T.leaf "dtest" ], T.leaf "etest"], T.Node "atest" [ T.Node "btest" [T.leaf "ctest" , T.leaf "dtest" ], T.leaf "etest"]]
      it "测试FunctorWithIndex" do
        mapWithIndex (\i _ -> i) forest1 `shouldEqual` 
          Forest [
            T.Node (NEA.cons' 0 []) [ 
              T.Node (NEA.cons' 0 [0]) [
                T.leaf (NEA.cons' 0 [0,0]) , 
                T.leaf (NEA.cons' 0 [0, 1])], 
              T.leaf (NEA.cons' 0 [1])],   
            T.Node (NEA.cons' 1 []) [ 
              T.Node (NEA.cons' 1 [0]) [
                T.leaf (NEA.cons' 1 [0,0]) , 
                T.leaf (NEA.cons' 1 [0, 1])], 
              T.leaf (NEA.cons' 1 [1])]
          ]