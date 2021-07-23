module App where


import Prelude

import Data.Array (head)
import Data.Maybe (Maybe(..))
import Data.UUID as UUID
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import IPFS as IPFS
import IPFS.OrbitDB.Docs (DocStore)
import IPFS.OrbitDB.Docs as ODocs
import IPFS.Orbitdb as OD
import RxDB.RxCollection (insertA)
import RxDB.Type (RxCollection)

type Input = { coll :: RxCollection }

type State = { 
    note :: String, 
    coll :: RxCollection
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
  Submit ->  do 
    note <- H.gets _.note
    coll <- H.gets _.coll
    uuid <- H.liftEffect UUID.genUUID
    void $ H.liftAff $ insertA coll { content: note,  noteId: (UUID.toString uuid)}
    H.modify_  _ { note = ""}
    -- pure unit
  InitNote -> do
    db <- H.liftAff getDocs
    rs <- H.liftEffect $ ODocs.get db "first"
    case head rs of
      Nothing -> pure unit
      Just doc -> do
        H.modify_  _ { note =  doc.content }

initialState :: Input-> State
initialState input = { note: "", coll: input.coll }

component :: forall q  o m. MonadAff m => H.Component q Input o m
component =
  H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval { 
      handleAction = handleAction
      -- , initialize = Just InitNote
       }
    }
