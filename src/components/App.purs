module App where


import IPFS.OrbitDB.Docs (DocStore)
import Prelude

import Data.Array (head)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Console (logShow, warnShow)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import IPFS as IPFS
import IPFS.OrbitDB.Docs as ODocs
import IPFS.Orbitdb as OD

type State = { 
    note :: String, 
    db :: Maybe ODocs.DocStore 
    }

data Action
  = Submit | SetNote String | InitNote

render :: forall cs m. State -> H.ComponentHTML Action cs m
render state =
  HH.div_
    [ 
      HH.div_ [ 
        HH.textarea 
          [ HP.placeholder "请在这里输入笔记内容！" 
            , HP.rows 5
            , HE.onValueInput \val -> SetNote val
            , HP.value state.note ]
          ]
    -- , HH.button [ HE.onClick \_ -> InitNote ] [ HH.text "加载" ]
    , HH.button [ HE.onClick \_ -> Submit ] [ HH.text "保存" ]

    ]

-- ren :: Maybe Doc -> 
getDocs :: Aff DocStore
getDocs = do
        ipfs <- IPFS.getGlobalIPFSA unit
        odb <- OD.createInstanceA_ ipfs 
        ODocs.docsA_ odb "notes"
 


handleAction :: forall cs o m . MonadAff m =>  Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  SetNote note -> do
    H.modify_ _ { note = note }
  Submit -> do 
    note <- H.gets _.note
    db <- H.gets _.db
    case db of
        Nothing -> do
          H.liftEffect $ warnShow "db未加载成功"
          pure unit
        Just db' -> do
          _ <-  H.liftAff $ ODocs.putA db' {_id: "first", content: note}
          H.liftEffect $ logShow $ "保存成功:" <> note
          pure unit
  InitNote -> do
    db <- H.liftAff getDocs
    rs <- H.liftEffect $ ODocs.get db "first"
    case head rs of
      Nothing -> pure unit
      Just doc -> do
        H.modify_  _ { db = Just db, note =  doc.content }

initialState :: forall i. i -> State
initialState _ = { note: "", db: Nothing }

component :: forall q i o m. MonadAff m => H.Component q i o m
component =
  H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval { 
      handleAction = handleAction
      , initialize = Just InitNote
       }
    }
