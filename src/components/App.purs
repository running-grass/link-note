module App where

import Prelude

import Control.Monad.State (state)
import Data.Array (head)
import Data.Either (note)
import Data.Maybe (Maybe(..))
import Data.UUID as UUID
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Console (logShow)
import Effect.Unsafe (unsafePerformEffect)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import IPFS as IPFS
import IPFS.OrbitDB.Docs (DocStore)
import IPFS.OrbitDB.Docs as ODocs
import IPFS.Orbitdb as OD
import RxDB.RxCollection (find, insertA)
import RxDB.RxDocument (toJSON)
import RxDB.RxQuery (execA)
import RxDB.Type (RxCollection, RxDocument, emptyQueryObject)
import Web.DOM.CharacterData (toNode)

type Input = { coll :: RxCollection Note}

type Note = { noteId :: String , content :: String }

type State = { 
    note :: String, 
    coll :: RxCollection Note,
    noteList :: Array Note 
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
    , HH.button [ HE.onClick \_ -> InitNote ] [ HH.text "加载" ]
    , HH.button [ HE.onClick \_ -> Submit ] [ HH.text "保存" ]
    , HH.ul_ $ (state.noteList <#> \note -> (HH.li_ [HH.text note.content]))
    ]

toNotes :: Array (RxDocument Note) ->  Array Note
toNotes ds = ds <#> toNote 
          
toNote  :: RxDocument Note -> Note 
toNote d = unsafePerformEffect $ toJSON d

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
    coll <- H.gets _.coll
    query <-  H.liftEffect $ find coll emptyQueryObject
    docs <- H.liftAff $  execA query
    let notes  = toNotes docs
    H.modify_  _ { noteList = notes }


initialState :: Input-> State
initialState input = { 
  note : "",
  coll : input.coll,
  noteList : []
  }

component :: forall q  o m. MonadAff m => H.Component q Input o m
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
