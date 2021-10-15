module LinkNote.Data.Array.Spec where

import Prelude

import Data.Array.NonEmpty as NA
import LinkNote.Data.Array (modifyAtHead, modifyAtLast, startsWith, startsWithNonEmptyArray)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec =
  describe "测试自定义的Array函数" do
    let a0 = []
    let a1 = [1,2,3]
    let a2 = [1,2,3,4,5]
    let n1 = NA.singleton 1
    let n2 = NA.cons' 1 [2,3]
    it "startsWith" do
      startsWith a0 a1 `shouldEqual` true
      startsWith a1 a0 `shouldEqual` false
      startsWith a1 a2 `shouldEqual` true
      startsWith a2 a1 `shouldEqual` false
    it "startsWithNonEmptyArray" do 
      startsWithNonEmptyArray (NA.cons' 0 a1) (NA.cons' 0 a2) `shouldEqual` true
      startsWithNonEmptyArray (NA.cons' 0 a2) (NA.cons' 0 a1) `shouldEqual` false
    it "modifyAtHead" do
      modifyAtHead (_ + 100) n1 `shouldEqual` NA.singleton 101
      modifyAtHead (_ + 100) n2 `shouldEqual` NA.cons' 101 [2,3]
    it "modifyAtLast" do
      modifyAtLast (_ + 100) n1 `shouldEqual` NA.singleton 101
      modifyAtLast (_ + 100) n2 `shouldEqual` NA.snoc' [1,2] 103
      