module App where

import Control.Monad.Rec.Class (forever)
import Control.Promise (Promise, toAffE)
import DOM.HTML.Indexed (FocusEvents)
import Data.Array (length, null)
import Data.Codec.Argonaut.Common (maybe)
import Data.Maybe (Maybe(..), fromMaybe, isNothing)
import Data.String.Regex (Regex, test, replace)
import Data.String.Regex.Flags (global)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.UUID as UUID
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, forkAff)
import Effect.Aff.Class (class MonadAff)
import Effect.Console (logShow)
import Effect.Unsafe (unsafePerformEffect)
import Halogen (PropName(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Subscription as HS
import Html.Renderer.Halogen as RH
import IPFS (IPFS)
import Prelude (Unit, bind, discard, otherwise, pure, unit, void, ($), (<#>), (<>), (=<<), (==))
import RxDB.RxCollection (bulkRemoveA, find, upsertA)
import RxDB.RxDocument (toJSON)
import RxDB.RxQuery (emptyQueryObject, execA)
import RxDB.Type (RxCollection, RxDocument)
import Util (logAny)
import Web.Clipboard.ClipboardEvent (toEvent)
import Web.DOM.Element (fromEventTarget, toNode)
import Web.DOM.Node (textContent)
import Web.Event.Event (Event, EventType(..), currentTarget, preventDefault, target)
import Web.Event.Internal.Types (EventTarget)
import Web.HTML.Event.EventTypes (blur, offline)
import Web.HTML.HTMLElement (blur, contentEditable)
import Web.UIEvent.FocusEvent (FocusEvent, relatedTarget)
import Web.UIEvent.KeyboardEvent as KE


foreign import doBlur :: EventTarget -> Effect Unit
foreign import innerText :: EventTarget -> Effect String
foreign import insertText :: String -> Effect Boolean 

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
  | HandleKeyUp String KE.KeyboardEvent
  | HandleKeyDown String KE.KeyboardEvent
  | InitComp
  | SubmitIpfs String
  | Delete String 
  | Edit String
  | Log String 
  | EditNote Event String 



foreign import addPasteListenner ::  IPFS -> (Function String (Effect Unit)) -> Effect Unit

foreign import getGatewayUri :: IPFS -> Effect (Promise String)


regFileLink :: Regex
regFileLink = unsafeRegex "\\[\\[file-(.*?)\\]\\]" global

getGatewayUriA :: IPFS -> Aff String
getGatewayUriA ipfs = toAffE $ getGatewayUri ipfs 

renderNote :: forall  a. String -> Maybe String ->  Note  -> HH.HTML a Action
renderNote ipfsGatway currentId note = 
  HH.li_ 
    [
      HH.div [ 
          HP.prop (PropName "contentEditable") true
        , HE.onKeyUp \kbe -> HandleKeyUp note.id kbe
        , HE.onKeyDown \kbe -> HandleKeyDown note.id kbe

        , HE.onFocus \_ -> Edit note.id 
        , HE.handler (EventType "input") \str -> EditNote str note.id
        , HP.style "min-width: 100px;min-height: 30px;"
      ] [ 
        case currentId of 
        Just id | id == note.id -> HH.text note.content
        _ -> RH.render_ $ replace regFileLink ("<img src=\"" <> ipfsGatway <> "$1\">") note.content 
      ]
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

getTextFromEvent :: Event -> Effect (Maybe String)
getTextFromEvent ev = do
  let maybeTarget = target ev
  case maybeTarget of 
    Nothing -> pure Nothing
    Just target -> do
      let maybeEle = fromEventTarget target
      case maybeEle of 
        Nothing -> pure Nothing 
        Just el -> do 
          text <- H.liftEffect $ textContent $ toNode el
          pure $ Just text
 
handleAction :: forall cs o m . MonadAff m =>  Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  New -> do
    coll <- H.gets _.coll
    uuid <- H.liftEffect UUID.genUUID
    let noteId = "note-" <> UUID.toString uuid
    void $ H.liftAff $ upsertA coll { content: "",  id: noteId, type: "text"  }
    handleAction InitNote
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
    
    let appendText = "[[" <> fileId <> "]]"
    _ <- H.liftEffect $ insertText appendText
    pure unit 

    -- note <- H.gets _.currentNote
    -- id <- H.gets _.currentId

    -- if isNothing id 
    -- then pure unit 
    -- else do
    --   let note' = fromMaybe "" note
    --   let id' = fromMaybe "" id 
    --   let newNote = note' <> 
    --   handleAction $ Submit id' newNote

  InitComp -> do
    handleAction InitNote
    ipfs <- H.gets _.ipfs
    -- _ <- H.subscribe =<< timer InitNote
    _ <- H.subscribe =<< subscriptPaste ipfs
    host <- H.liftAff $ getGatewayUriA ipfs
    H.modify_ _ { ipfsGatway = Just (host <> "/ipfs/") }
  InitNote -> do
    coll <- H.gets _.coll
    query <-  H.liftEffect $ find coll emptyQueryObject
    docs <- H.liftAff $  execA query
    let notes  = toNotes docs
    if null notes 
      then handleAction New 
      else H.modify_  _ { noteList = notes }
  Delete noteId -> do
    coll <- H.gets _.coll
    H.liftAff $ bulkRemoveA coll [noteId]
    handleAction InitNote
    H.modify_ _ { currentId = Nothing, currentNote = Nothing }
  HandleKeyDown id kbe 
    | KE.key kbe == "Enter" -> do 
      H.liftEffect $ preventDefault $ KE.toEvent kbe
      handleAction New
    | otherwise -> pure unit

  HandleKeyUp id kbe 
    | KE.key kbe == "Escape" -> do 
        let maybeTarget = currentTarget $ KE.toEvent kbe
        case maybeTarget of
          Just target -> do 
            H.liftEffect $ doBlur target  
          Nothing -> pure unit
        handleAction InitNote
        H.modify_ _ { currentId = Nothing, currentNote = Nothing }
    | KE.key kbe == "Backspace" -> do 
      maybeText <- H.liftEffect $ getTextFromEvent $ KE.toEvent kbe
      case maybeText of 
        Nothing -> pure unit
        Just text 
          | "" == text -> handleAction $ Delete id 
          | otherwise -> pure unit 
    | otherwise -> pure unit
  EditNote ev id -> do 
    maybeText <- H.liftEffect $ getTextFromEvent ev
    case maybeText of 
      Nothing -> pure unit
      Just text -> do
        _ <- pure $ logAny text
        handleAction $ Submit id text
  Edit noteId  -> do
    H.modify_ _ { currentId = Just noteId }
    handleAction InitNote
  Log str -> do 
    H.liftEffect $ logShow str 

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
