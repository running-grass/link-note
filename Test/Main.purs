module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import LinkNote.Data.Tree.Spec as TreeSpec
import LinkNote.Data.Array.Spec as ArraySpec
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

main :: Effect Unit
main = launchAff_ $ runSpec [consoleReporter] do
    ArraySpec.spec
    TreeSpec.spec