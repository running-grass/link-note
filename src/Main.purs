module Main 
  where

import Prelude

import App as App
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Aff (Aff, throwError)
import Effect.Exception (error)
import Halogen.Aff (awaitLoad, selectElement)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.HTML (HTMLElement)

foreign import logAny :: forall a . a -> Effect Unit

-- | Waits for the document to load and then finds the `body` element.
awaitRoot :: Aff HTMLElement
awaitRoot = do
  awaitLoad
  ele <- selectElement (QuerySelector "#halogen-app")
  maybe (throwError (error "找不到根节点！")) pure ele

main :: Effect Unit
main = do
  -- launchAff_ do
  --   ipfs <- IPFS.getGlobalIPFSA unit
  --   odb <- OD.createInstanceA ipfs (fromRecord {})
  --   db <- ODocs.docsA odb (OD.DBName "notes") (fromRecord {}) 
  --   liftEffect $ logAny db
  --   -- pure unit
  HA.runHalogenAff do
    app <- awaitRoot
    runUI App.component unit app