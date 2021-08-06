module App where

import IPFS (IPFS)
import Prelude (Unit, bind, discard, otherwise, pure, unit, void, ($), (<#>), (<>), (=<<), (==))

import Control.Monad.Rec.Class (forever)
import Control.Promise (Promise, toAffE)
import Data.Maybe (Maybe(..), fromMaybe, isNothing)
import Data.String.Regex (Regex, test, replace)
import Data.String.Regex.Flags (global)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.UUID as UUID
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, forkAff)
import Effect.Aff.Class (class MonadAff)
import Effect.Unsafe (unsafePerformEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Subscription as HS
import Html.Renderer.Halogen as RH
import RxDB.RxCollection (bulkRemoveA, find, upsertA)
import RxDB.RxDocument (toJSON)
import RxDB.RxQuery (emptyQueryObject, execA)
import RxDB.Type (RxCollection, RxDocument)
import Web.UIEvent.KeyboardEvent as KE


type Input = { 
  coll :: RxCollection Note, 
  collFile :: RxCollection File,
  ipfs :: IPFS 
  }

type Note =  Record ( 
  id :: String , 
  content :: String, 
  type :: String 
  )

type File = Record (
  id :: String , 
  cid :: String, 
  mime :: String,
  type :: String 
)

type State = { 
    currentId :: Maybe String,
    currentNote :: Maybe String,
    note :: String, 
    coll :: RxCollection Note,
    collFile :: RxCollection File,
    noteList :: Array Note,
    ipfs :: IPFS,
    ipfsGatway :: Maybe String
    }

data Action
  = Submit String String 
  | SetNote String 
  | InitNote 
  | New
  | HandleKeyUp KE.KeyboardEvent
  | InitComp
  | SubmitIpfs String
  | Delete String 
  | Edit String String



foreign import addPasteListenner ::  IPFS -> (Function String (Effect Unit)) -> Effect Unit

foreign import getGatewayUri :: IPFS -> Effect (Promise String)


regFileLink :: Regex
regFileLink = unsafeRegex "\\[\\[file-(.*?)\\]\\]" global

getGatewayUriA :: IPFS -> Aff String
getGatewayUriA ipfs = toAffE $ getGatewayUri ipfs 

renderViewNote :: forall a . String -> Note -> HH.HTML a Action
renderViewNote ipfsGatway note = if test regFileLink note.content 
        then RH.render_ $ replace regFileLink ("<img src=\"" <> ipfsGatway <> "$1\">") note.content 
        else  HH.text $ " " <> note.content

renderEditNote :: forall a . Note -> HH.HTML a Action
renderEditNote note = HH.div_ [
  HH.textarea [ 
    HP.placeholder "请在这里输入笔记内容！" 
    , HP.rows 3
    , HE.onValueInput \val -> Submit note.id val
    , HE.onKeyUp \kbe -> HandleKeyUp kbe
    , HP.value note.content 
    ]
  ]


renderNote :: forall  a. String -> Maybe String ->  Note  -> HH.HTML a Action
renderNote ipfsGatway currentId note = 
  HH.li_ 
    [
      HH.button [ HE.onClick \_ -> Delete note.id ] [ HH.text "删除" ]
      , HH.button [ HE.onClick \_ -> Edit note.id note.content ] [ HH.text "编辑" ]
      , case currentId of
        Nothing -> renderViewNote ipfsGatway note
        Just id -> if id == note.id then renderEditNote note  else renderViewNote ipfsGatway note
    ]



render :: forall cs m. State -> H.ComponentHTML Action cs m
render state =
  HH.div_
    [ 
    HH.ul_ $ state.noteList <#> renderNote (fromMaybe "ipfs://" state.ipfsGatway) state.currentId
    ]
    

toNotes :: Array (RxDocument Note) ->  Array Note
toNotes ds = ds <#> toNote 
          
toNote  :: RxDocument Note -> Note 
toNote d = unsafePerformEffect $ toJSON d
 
handleAction :: forall cs o m . MonadAff m =>  Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  New -> do
    coll <- H.gets _.coll
    uuid <- H.liftEffect UUID.genUUID
    let noteId = "note-" <> UUID.toString uuid
    void $ H.liftAff $ upsertA coll { content: "",  id: noteId, type: "text"  }
    H.modify_  _ { currentId = Just noteId, currentNote = Just "" }
  SetNote note -> do
    H.modify_ _ { note = note }
  Submit noteId note->  do
    coll <- H.gets _.coll
    void $ H.liftAff $ upsertA coll { content: note,  id: noteId, type: "text"  }
    H.modify_  _ { note = "" }
  SubmitIpfs path -> do
    collFile <- H.gets _.collFile

    let fileId = "file-" <> path
    void $ H.liftAff $ upsertA collFile { cid: path,  id: fileId, mime: "", type: "" }
    
    note <- H.gets _.currentNote
    id <- H.gets _.currentId

    if isNothing id 
    then pure unit 
    else do
      let note' = fromMaybe "" note
      let id' = fromMaybe "" id 
      let newNote = note' <> "[[" <> fileId <> "]]"
      handleAction $ Submit id' newNote

  InitComp -> do
    ipfs <- H.gets _.ipfs
    _ <- H.subscribe =<< timer InitNote
    _ <- H.subscribe =<< subscriptPaste ipfs
    host <- H.liftAff $ getGatewayUriA ipfs
    H.modify_ _ { ipfsGatway = Just (host <> "/ipfs/") }
  InitNote -> do
    coll <- H.gets _.coll
    query <-  H.liftEffect $ find coll emptyQueryObject
    docs <- H.liftAff $  execA query
    let notes  = toNotes docs
    H.modify_  _ { noteList = notes }
  Delete noteId -> do
    coll <- H.gets _.coll
    H.liftAff $ bulkRemoveA coll [noteId]
    H.modify_ _ { currentId = Nothing, currentNote = Nothing }
  HandleKeyUp kbe 
    | KE.key kbe == "Enter" -> handleAction New
    | KE.key kbe == "Escape" -> H.modify_ _ { currentId = Nothing, currentNote = Nothing }
    | otherwise -> pure unit
  Edit noteId content -> do
    H.modify_ _ { currentId = Just noteId, currentNote = Just content }

initialState :: Input-> State
initialState input = { 
  currentId: Nothing,
  currentNote: Nothing,
  ipfsGatway: Nothing,
  note : "",
  coll : input.coll,
  collFile : input.collFile,
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
