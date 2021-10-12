module LinkNote.Test.Data.Tree.Spec where

import Prelude

import Data.Array as A
import Data.Array.NonEmpty as NEA
import Data.Foldable (foldl, foldr)
import Data.FoldableWithIndex (findWithIndex, foldlWithIndex, foldrWithIndex)
import Data.FunctorWithIndex (mapWithIndex)
import Data.Maybe (Maybe(..))
import LinkNote.Data.Tree (Forest(..))
import LinkNote.Data.Tree as T
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec =
  describe "测试Tree及Forest" do
    let tree1 = T.mkNode 1 [T.mkNode 2 [T.leaf 3, T.leaf 4], T.mkNode 5 [T.leaf 6, T.leaf 7]] 
    let treeString = T.mkNode "a" [ T.mkNode "b" [T.leaf "c" , T.leaf "d" ], T.leaf "e"]
    let forest1 = Forest [treeString, treeString]
    let forest2 = Forest [tree1, tree1]
    let forest3 = Forest [tree1]
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
          mapWithIndex (\i _ -> i) treeString `shouldEqual` T.mkNode [] [ T.mkNode [0] [T.leaf [0, 0] , T.leaf [0, 1] ], T.leaf [1]]
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
        map (\t -> t <> "test") forest1 `shouldEqual` Forest [T.mkNode "atest" [ T.mkNode "btest" [T.leaf "ctest" , T.leaf "dtest" ], T.leaf "etest"], T.mkNode "atest" [ T.mkNode "btest" [T.leaf "ctest" , T.leaf "dtest" ], T.leaf "etest"]]
      it "测试FunctorWithIndex" do
        mapWithIndex (\i _ -> i) forest1 `shouldEqual` 
          Forest [
            T.mkNode (NEA.cons' 0 []) [ 
              T.mkNode (NEA.cons' 0 [0]) [
                T.leaf (NEA.cons' 0 [0,0]) , 
                T.leaf (NEA.cons' 0 [0, 1])], 
              T.leaf (NEA.cons' 0 [1])],   
            T.mkNode (NEA.cons' 1 []) [ 
              T.mkNode (NEA.cons' 1 [0]) [
                T.leaf (NEA.cons' 1 [0,0]) , 
                T.leaf (NEA.cons' 1 [0, 1])], 
              T.leaf (NEA.cons' 1 [1])]
          ]
        T.modify (const 110) (NEA.cons' 0 [0, 0]) forest3 `shouldEqual` Forest [T.mkNode 1 [T.mkNode 2 [T.leaf 110, T.leaf 4], T.mkNode 5 [T.leaf 6, T.leaf 7]] ]
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
        T.findSubTree (\n -> n == "b") treeString `shouldEqual` Just (T.mkNode "b" [T.leaf "c" , T.leaf "d" ])
        T.findTree (\n -> n == "b") forest1 `shouldEqual` Just (T.mkNode "b" [T.leaf "c" , T.leaf "d" ])        
        T.findChildrenByTree (\n -> n == "b") forest1 `shouldEqual` Just ["c", "d"]