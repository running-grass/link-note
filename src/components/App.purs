module App where

import IPFS
import Prelude

import Control.Monad.Rec.Class (forever)
import Control.Promise (Promise, toAffE)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.UUID as UUID
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, forkAff)
import Effect.Aff.Class (class MonadAff)
import Effect.Console (logShow)
import Effect.Unsafe (unsafePerformEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Subscription as HS
import Option as Option
import RxDB.RxCollection (bulkRemoveA, find, findOne, upsertA)
import RxDB.RxDocument (isRxDocument, toJSON)
import RxDB.RxQuery (emptyQueryObject, execA, primaryQuery)
import RxDB.Type (RxCollection, RxDocument)

type Input = { coll :: RxCollection Note, ipfs :: IPFS }

type Note =  Record ( noteId :: String , content :: String, type :: String )


type State = { 
    currentId :: Maybe String,
    note :: String, 
    coll :: RxCollection Note,
    noteList :: Array Note,
    ipfs :: IPFS,
    ipfsGatway :: Maybe String
    }

data Action
  = Submit 
  | SetNote String 
  | InitNote 
  | InitComp
  | SubmitIpfs String
  | Delete String 
  | Edit String



foreign import addPasteListenner ::  IPFS -> (Function String (Effect Unit)) -> Effect Unit

foreign import getGatewayUri :: IPFS -> Effect (Promise String)


getGatewayUriA :: IPFS -> Aff String
getGatewayUriA ipfs = toAffE $ getGatewayUri ipfs 

renderNote :: forall  a. String ->  Note  -> HH.HTML a Action
renderNote ipfsGatway  note = 
  HH.li_ 
    [
      HH.button [ HE.onClick \_ -> Delete note.noteId ] [ HH.text "删除" ]
      , HH.button [ HE.onClick \_ -> Edit note.noteId ] [ HH.text "编辑" ]
      , if note.type == "ipfs" 
        then HH.img [ HP.src $ ipfsGatway <> note.content,
        HP.width 200]
        else  HH.text $ " " <> note.content
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
    , HH.ul_ $ state.noteList <#> renderNote (fromMaybe "ipfs://" state.ipfsGatway)
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
    void $ H.liftAff $ upsertA coll { content: note,  noteId: noteId, type: "text" }
    H.modify_  _ { note = ""}
  SubmitIpfs path -> do
    -- note <- H.gets _.note
    coll <- H.gets _.coll
    -- currentId <- H.gets _.currentId
    uuid <- H.liftEffect UUID.genUUID
    let noteId = UUID.toString uuid
    void $ H.liftAff $ upsertA coll { content: path,  noteId: noteId, type: "ipfs" }
    H.modify_  _ { note = ""}
  InitComp -> do
    ipfs <- H.gets _.ipfs
    _ <- H.subscribe =<< timer InitNote
    _ <- H.subscribe =<< subscriptPaste ipfs
    host <- H.liftAff $ getGatewayUriA ipfs
    H.modify_ _ { ipfsGatway = Just (host <> "/ipfs/") }
    -- pure unit
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
  ipfsGatway: Nothing,
  note : "",
  coll : input.coll,
  ipfs : input.ipfs,
  noteList : []
  }

timer :: forall m a. MonadAff m => a -> m (HS.Emitter a)
timer val = do
  { emitter, listener } <- H.liftEffect HS.create
  _ <- H.liftAff $ forkAff $ forever do
    delay $ Milliseconds 1000.0
    H.liftEffect $ HS.notify listener val
  pure emitter

subscriptPaste :: forall m. MonadAff m => IPFS -> m (HS.Emitter Action)
subscriptPaste ipfs = do
  { emitter, listener } <- H.liftEffect HS.create
  _ <- H.liftEffect $ addPasteListenner ipfs (\path -> HS.notify listener $ SubmitIpfs path)
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
