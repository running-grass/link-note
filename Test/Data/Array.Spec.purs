module LinkNote.Data.Array.Spec where

import Prelude

import Data.Array.NonEmpty as NA
import LinkNote.Data.Array (startsWith, startsWithNonEmptyArray)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec =
  describe "测试自定义的Array函数" do
    let a0 = []
    let a1 = [1,2,3]
    let a2 = [1,2,3,4,5]
    it "startsWith" do
      startsWith a0 a1 `shouldEqual` true
      startsWith a1 a0 `shouldEqual` false
      startsWith a1 a2 `shouldEqual` true
      startsWith a2 a1 `shouldEqual` false
    it "startsWithNonEmptyArray" do 
      startsWithNonEmptyArray (NA.cons' 0 a1) (NA.cons' 0 a2) `shouldEqual` true
      startsWithNonEmptyArray (NA.cons' 0 a2) (NA.cons' 0 a1) `shouldEqual` false