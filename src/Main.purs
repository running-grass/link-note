module Main where

import Prelude

import App.Button as Button
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Aff (Aff, throwError)
import Effect.Exception (error)
import Halogen.Aff (awaitLoad, selectElement)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Test (getdb)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.HTML (HTMLElement)


-- | Waits for the document to load and then finds the `body` element.
awaitApp :: Aff HTMLElement
awaitApp = do
  awaitLoad
  ele <- selectElement (QuerySelector "#halogen-app")
  maybe (throwError (error "找不到根节点！")) pure ele

main :: Effect Unit
-- main = HA.runHalogenAff do
--   app <- awaitApp
--   runUI Button.component unit app
main = do
  getdb "key-val"
