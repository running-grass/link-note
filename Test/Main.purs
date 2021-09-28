module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import LinkNote.Test.Data.Tree.Spec as TreeSpec
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

main :: Effect Unit
main = launchAff_ $ runSpec [consoleReporter] do
    TreeSpec.spec