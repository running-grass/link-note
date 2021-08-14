module LinkNote.Page.Home where

import Control.Monad.Rec.Class (forever)
import Control.Promise (Promise, toAffE)
import Data.Array (null)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String.Regex (Regex, replace)
import Data.String.Regex.Flags (global)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.UUID as UUID
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, forkAff)
import Effect.Aff.Class (class MonadAff)
import Effect.Unsafe (unsafePerformEffect)
import Halogen (ClassName(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Store.Connect (Connected, connect)
import Halogen.Store.Monad (class MonadStore)
import Halogen.Store.Select (selectAll)
import Halogen.Subscription as HS
import Html.Renderer.Halogen as RH
import IPFS (IPFS)
import LinkNote.Component.HTML.Header (header)
import LinkNote.Component.Store as LS
import LinkNote.Component.Util (logAny)
import LinkNote.Data.Data (Note, File)
import Prelude (Unit, bind, discard, not, otherwise, pure, unit, void, when, ($), (<#>), (<<<), (<>), (=<<), (==))
import RxDB.RxCollection (bulkRemoveA, find, insertA, upsertA)
import RxDB.RxDocument (toJSON)
import RxDB.RxQuery (emptyQueryObject, execA)
import RxDB.Type (RxCollection, RxDocument)
import Unsafe.Reference (unsafeRefEq)
import Web.Clipboard.ClipboardEvent as CE
import Web.Event.Event (Event, currentTarget, preventDefault, target)
import Web.Event.Internal.Types (EventTarget)
import Web.HTML.HTMLTextAreaElement as HTAE
import Web.UIEvent.KeyboardEvent as KE


foreign import doBlur :: EventTarget -> Effect Unit
foreign import innerText :: EventTarget -> Effect String
foreign import insertText :: String -> Effect Boolean 
foreign import autoFocus :: String -> Effect Unit 
foreign import nowTime :: Effect Int 

type State = { 
    currentId :: Maybe String,
    coll :: RxCollection Note,
    collFile :: RxCollection File,
    noteList :: Array Note,
    ipfs :: Maybe IPFS,
    ipfsGatway :: Maybe String
    }

type ConnectedInput = Connected LS.Store Unit

data Action
  = Submit String String 
  | InitNote 
  | New
  | IgnorePaste CE.ClipboardEvent
  | HandleKeyUp String KE.KeyboardEvent
  | HandleKeyDown String KE.KeyboardEvent
  | InitComp
  | Receive ConnectedInput
  | SubmitIpfs String
  | Delete String 
  | Edit String
  | EditNote Event String 
  | ChangeEditID (Maybe String)

foreign import addPasteListenner :: (forall a. a -> Maybe a -> a) -> Maybe IPFS -> (Function String (Effect Unit)) -> Effect Unit

foreign import getGatewayUri :: IPFS -> Effect (Promise String)

regFileLink :: Regex
regFileLink = unsafeRegex "\\[\\[file-(.*?)\\]\\]" global

getGatewayUriA :: IPFS -> Aff String
getGatewayUriA ipfs = toAffE $ getGatewayUri ipfs 

renderNote :: forall  a. String -> Maybe String ->  Note  -> HH.HTML a Action
renderNote ipfsGatway currentId note = 
  HH.li [ 
    HP.id note.id 
    , HE.onClick \_ -> Edit note.id 
    , HP.style "min-height: 30px;"
    ] 
    [
      case currentId of 
      Just id | id == note.id -> HH.textarea [
        HP.value note.content
        , HP.style "min-width: 100px;min-height: 30px;" 
        , HE.onKeyUp \kbe -> HandleKeyUp note.id kbe
        , HE.onKeyDown \kbe -> HandleKeyDown note.id kbe
        , HE.onPaste IgnorePaste
        , HE.onValueInput \val -> Submit note.id val
        -- , HE.onBlur \_ -> ChangeEditID Nothing
      ]

      _ -> HH.div [ 
        HP.class_ $ ClassName "head"
      ] [ 
        RH.render_ $ replace regFileLink ("<img src=\"" <> ipfsGatway <> "$1\">") note.content 
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
      
      let maybeInput = HTAE.fromEventTarget target
      case maybeInput of 
        Nothing -> pure $ Just "-1" 
        Just el -> do 
          text <- H.liftEffect $ HTAE.value el
          pure $ Just text
 
handleAction :: forall cs o m . MonadAff m =>  Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  ChangeEditID mb -> do 
    H.modify_ _ { currentId = mb}
    handleAction InitNote
    case mb of 
      Just id -> H.liftEffect $ autoFocus id
      Nothing -> pure unit
  New -> do
    coll <- H.gets _.coll
    -- now <- H.liftEffect nowTime
    uuid <- H.liftEffect UUID.genUUID
    let noteId = "note-" <> UUID.toString uuid
    void $ H.liftAff $ insertA coll { content: "",  id: noteId }
    handleAction $ ChangeEditID $ Just noteId
  Submit noteId note->  do
    coll <- H.gets _.coll
    void $ H.liftAff $ upsertA coll { content: note,  id: noteId }
    pure unit 
  SubmitIpfs path -> do
    collFile <- H.gets _.collFile

    let fileId = "file-" <> path
    void $ H.liftAff $ upsertA collFile { cid: path,  id: fileId, mime: "", type: "" }
    
    let appendText = "[[" <> fileId <> "]]"
    _ <- H.liftEffect $ insertText appendText
    pure unit 

  InitComp -> do
    handleAction InitNote
    maybeIpfs <- H.gets _.ipfs
    _ <- H.subscribe =<< subscriptPaste maybeIpfs
    case maybeIpfs of 
      Just ipfs -> do
        host <- H.liftAff $ getGatewayUriA ipfs
        H.modify_ _ { ipfsGatway = Just (host <> "/ipfs/") }
      _ -> do
        pure unit
  InitNote -> do
    coll <- H.gets _.coll
    query <-  H.liftEffect $ find coll emptyQueryObject
    docs <- H.liftAff $ execA query
    let notes  = toNotes docs
    if null notes 
      then handleAction New 
      else H.modify_  _ { noteList = notes }
  Delete noteId -> do
    coll <- H.gets _.coll
    H.liftAff $ bulkRemoveA coll [noteId]
    handleAction $ ChangeEditID $ Nothing
  HandleKeyDown id kbe 
    | KE.key kbe == "Enter" -> do 
      H.liftEffect $ preventDefault $ KE.toEvent kbe
    | otherwise -> pure unit

  HandleKeyUp id kbe 
    | KE.key kbe == "Enter" -> do 
      H.liftEffect $ preventDefault $ KE.toEvent kbe
      handleAction New
    | KE.key kbe == "Escape" -> do 
        handleAction $ ChangeEditID Nothing
        let maybeTarget = currentTarget $ KE.toEvent kbe
        case maybeTarget of
          Just target -> do 
            H.liftEffect $ doBlur target
          Nothing -> pure unit

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
        handleAction $ Submit id text
  Edit noteId  -> do
    handleAction $ ChangeEditID $ Just noteId
  IgnorePaste ev -> H.liftEffect $ preventDefault $ CE.toEvent ev
  Receive { context } -> do
    ipfs <- H.gets _.ipfs 
    let ipfs' = context.ipfs
    when (isUpdate ipfs ipfs') do
      H.modify_ _ { ipfs = ipfs' }
      handleAction InitComp
    pure unit
    where
      isUpdate :: Maybe IPFS -> Maybe IPFS -> Boolean
      isUpdate Nothing Nothing = false
      isUpdate (Just x) (Just y) = not $ unsafeRefEq (logAny x) (logAny y)
      isUpdate _ _ = true

initialState :: ConnectedInput-> State
initialState { context } = { 
  currentId: Nothing,
  ipfsGatway: Nothing,
  coll : context.collNote,
  collFile : context.collFile,
  ipfs : context.ipfs,
  noteList : []
  }

timer :: forall m a. MonadAff m => a -> m (HS.Emitter a)
timer val = do
  { emitter, listener } <- H.liftEffect HS.create
  _ <- H.liftAff $ forkAff $ forever do
    delay $ Milliseconds 1000.0
    H.liftEffect $ HS.notify listener val
  pure emitter

subscriptPaste :: forall m. MonadAff m => Maybe IPFS -> m (HS.Emitter Action)
subscriptPaste ipfs = do
  { emitter, listener } <- H.liftEffect HS.create
  _ <- H.liftEffect $ addPasteListenner fromMaybe ipfs (\path -> HS.notify listener $ SubmitIpfs path)
  pure emitter

component :: forall q  o m.  MonadStore LS.Action LS.Store m => MonadAff m => H.Component q Unit o m
component =
  connect selectAll $ H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval { 
        handleAction = handleAction
      , initialize = Just InitComp
      , receive = Just <<< Receive
      }
    }