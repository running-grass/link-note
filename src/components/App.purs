module App where

import Prelude

import Control.Monad.Rec.Class (forever)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.UUID as UUID
import Effect.Aff (Milliseconds(..), delay, forkAff)
import Effect.Aff.Class (class MonadAff)
import Effect.Unsafe (unsafePerformEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Subscription as HS
import RxDB.RxCollection (bulkRemoveA, find, findOne, upsertA)
import RxDB.RxDocument (isRxDocument, toJSON)
import RxDB.RxQuery (emptyQueryObject, execA, primaryQuery)
import RxDB.Type (RxCollection, RxDocument)

type Input = { coll :: RxCollection Note}

type Note = { noteId :: String , content :: String }

type State = { 
    currentId :: Maybe String,
    note :: String, 
    coll :: RxCollection Note,
    noteList :: Array Note
    }

data Action
  = Submit 
  | SetNote String 
  | InitNote 
  | InitComp
  | Delete String 
  | Edit String

renderNote :: forall  a. Note  -> HH.HTML a Action
renderNote note = 
  HH.li_ 
    [
      HH.button [ HE.onClick \_ -> Delete note.noteId ] [ HH.text "删除" ]
      , HH.button [ HE.onClick \_ -> Edit note.noteId ] [ HH.text "编辑" ]
      , HH.text $ " " <> note.content
    ]

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
    , HH.ul_ $ state.noteList <#> renderNote
    ]

toNotes :: Array (RxDocument Note) ->  Array Note
toNotes ds = ds <#> toNote 
          
toNote  :: RxDocument Note -> Note 
toNote d = unsafePerformEffect $ toJSON d
 
handleAction :: forall cs o m . MonadAff m =>  Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  SetNote note -> do
    H.modify_ _ { note = note }
  Submit ->  do 
    note <- H.gets _.note
    coll <- H.gets _.coll
    currentId <- H.gets _.currentId
    uuid <- H.liftEffect UUID.genUUID
    let noteId = fromMaybe (UUID.toString uuid) currentId
    void $ H.liftAff $ upsertA coll { content: note,  noteId: noteId }
    H.modify_  _ { note = ""}
  InitComp -> do
    _ <- H.subscribe =<< timer InitNote
    pure unit
  InitNote -> do
    coll <- H.gets _.coll
    query <-  H.liftEffect $ find coll emptyQueryObject
    docs <- H.liftAff $  execA query
    let notes  = toNotes docs
    H.modify_  _ { noteList = notes }
  Delete noteId -> do
    coll <- H.gets _.coll
    H.liftAff $ bulkRemoveA coll [noteId]
  Edit noteId -> do
    coll <- H.gets _.coll
    q <- H.liftEffect $ findOne coll $ primaryQuery noteId
    doc' <- H.liftAff $ execA q
    isDoc <- H.liftEffect $ isRxDocument doc'
    when isDoc do
      note <- H.liftEffect $ toJSON doc'
      H.modify_  _ { currentId = Just note.noteId, note = note.content }

initialState :: Input-> State
initialState input = { 
  currentId: Nothing,
  note : "",
  coll : input.coll,
  noteList : []
  }

timer :: forall m a. MonadAff m => a -> m (HS.Emitter a)
timer val = do
  { emitter, listener } <- H.liftEffect HS.create
  _ <- H.liftAff $ forkAff $ forever do
    delay $ Milliseconds 1000.0
    H.liftEffect $ HS.notify listener val
  pure emitter

component :: forall q  o m. MonadAff m => H.Component q Input o m
component =
  H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval { 
        handleAction = handleAction
      , initialize = Just InitComp
      }
    }
