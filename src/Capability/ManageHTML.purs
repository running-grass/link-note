module LinkNote.Capability.ManageHTML where

import Prelude

import Data.Maybe (Maybe(..))
import Data.String (splitAt)
import Effect.Class (class MonadEffect, liftEffect)
import Halogen (HalogenM, lift, liftEffect)
import LinkNote.Data.Data (CaretInfo)
import Web.HTML (HTMLDocument, HTMLElement, Window)
import Web.HTML.HTMLDocument as HD
import Web.HTML.HTMLElement as HE
import Web.HTML.HTMLInputElement as HIE
import Web.HTML.HTMLTextAreaElement as HTE
import Web.HTML.Window as W
import Web.Storage.Storage (Storage)

class (Monad m , MonadEffect m) <=  ManageHTML m where
  window :: m Window
  -- document :: m HTMLDocument

instance ManageHTML m => ManageHTML (HalogenM st act slots msg m) where
  window = lift window

document :: forall m . ManageHTML m => m HTMLDocument 
document = do
  window' <- window
  liftEffect $ W.document window'

localStorage :: forall m. ManageHTML m => m Storage
localStorage = do
  window' <- window
  liftEffect $ W.localStorage window'


activeElement :: forall m. ManageHTML m => m (Maybe HTMLElement)
activeElement = do
  doc <- document
  liftEffect $ HD.activeElement doc

getActiveElementReact :: forall m. ManageHTML m => m (Maybe HE.DOMRect)
getActiveElementReact = do
  ae <- activeElement
  case ae of 
    Nothing -> pure Nothing
    Just ae' -> do
      r <- liftEffect $ HE.getBoundingClientRect ae'
      pure $ Just r

-- 获取当前激活输入元素中的输入焦点信息
getCaretInfo :: forall m . ManageHTML m => m (Maybe CaretInfo)
getCaretInfo = do
  ae <- activeElement
  case ae of
    Nothing -> pure Nothing
    Just ae' -> do
      let ele = HE.toElement ae'
      let maybeTextarea = HTE.fromElement ele
      let maybeInput = HIE.fromElement ele 
      case maybeTextarea, maybeInput of 
        Just textarea, _ -> do
          val <- liftEffect $ HTE.value textarea
          start <- liftEffect $ HTE.selectionStart textarea
          end <- liftEffect $ HTE.selectionEnd textarea
          return ae' val start end
        Nothing, Just input -> do 
          val <- liftEffect $ HIE.value input
          start <- liftEffect $ HIE.selectionStart input
          end <- liftEffect $ HIE.selectionEnd input
          return ae' val start end
        _,_ -> pure Nothing 
  where 
    return el val start end = do
      if start /= end 
      then pure Nothing
      else pure $ Just $ genCarentInfo el start val
    genCarentInfo element position value = {
      position
      , element
      , beforeText
      , afterText
    }
      where
        splited = splitAt position value
        beforeText = splited.before
        afterText = splited.after