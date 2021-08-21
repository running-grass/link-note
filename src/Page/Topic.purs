module LinkNote.Page.Topic where

import Prelude

import Control.Alternative (empty, guard)
import Data.Array (filter, findIndex, index, null)
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Data.String.Regex (Regex, replace)
import Data.String.Regex.Flags (global)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.UUID as UUID
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
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
import LinkNote.Capability.ManageIPFS (class ManageIPFS, getIpfsGatewayPrefix)
import LinkNote.Capability.Now (class Now, now)
import LinkNote.Capability.Resource.Note (class ManageNote, addNote, deleteNote, getAllNotesByHostId, updateNoteById)
import LinkNote.Capability.Resource.Topic (class ManageTopic)
import LinkNote.Component.HTML.Utils (css)
import LinkNote.Component.Store as LS
import LinkNote.Component.Util (logAny)
import LinkNote.Data.Data (File, Note, TopicId, NoteId)
import RxDB.RxCollection (upsertA)
import RxDB.Type (RxCollection)
import Unsafe.Reference (unsafeRefEq)
import Web.Clipboard.ClipboardEvent as CE
import Web.DOM.ParentNode (children)
import Web.Event.Event (Event, currentTarget, preventDefault, stopPropagation, target)
import Web.Event.Internal.Types (EventTarget)
import Web.HTML.HTMLTextAreaElement as HTAE
import Web.UIEvent.KeyboardEvent as KE
import Web.UIEvent.MouseEvent as ME


foreign import doBlur :: EventTarget -> Effect Unit
foreign import innerText :: EventTarget -> Effect String
foreign import insertText :: String -> Effect Boolean 
foreign import autoFocus :: String -> Effect Unit 

newtype NoteNode = NoteNode {
  id :: NoteId
  , heading :: String
  , children :: Array NoteNode
}

type State = { 
    topicId :: TopicId,
    currentId :: Maybe String,
    collFile :: RxCollection File,
    noteList :: Array Note,
    renderNoteList :: Array NoteNode,
    ipfs :: Maybe IPFS,
    ipfsGatway :: String
    }

type Input = {
  topicId :: TopicId
}

type ConnectedInput = Connected LS.Store Input

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
  | Indent NoteId
  | EditNote Event String 
  | ClickNote ME.MouseEvent NoteId
  | ChangeEditID (Maybe String)


foreign import addPasteListenner :: (forall a. a -> Maybe a -> a) -> Maybe IPFS -> (Function String (Effect Unit)) -> Effect Unit


noteToTree :: Array Note -> NoteId -> Array NoteNode
noteToTree notelist parentId = filterdList <#> toTree
  where
    filterdList = filter (\note -> note.parentId == parentId) notelist
    toTree note = NoteNode {
      id: note.id
      , heading: note.heading
      , children: noteToTree notelist note.id
    }

searchPrevNoteId :: Array Note -> NoteId -> Maybe NoteId
searchPrevNoteId [] _ = Nothing
searchPrevNoteId [_] _ = Nothing
searchPrevNoteId notes id = do
  idx <- findIndex (\note -> note.id == id) notes
  if idx == 0 then Nothing else do
    note <- index notes $ idx - 1
    pure note.id



regFileLink :: Regex
regFileLink = unsafeRegex "\\[\\[file-(.*?)\\]\\]" global

renderNote :: forall  a. String -> Maybe String -> Int ->  NoteNode -> HH.HTML a Action
renderNote ipfsGatway currentId level (NoteNode note)  = 
  HH.li [ 
    HP.id note.id 
    , HE.onClick \ev -> ClickNote ev note.id 

    , HP.style "min-height: 30px;"
    , css $ "pl-" <> (show 8)
    ] 
    [
      case currentId of 
      Just id | id == note.id -> HH.textarea [
        HP.value note.heading
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
        RH.render_ $ replace regFileLink ("<img src=\"" <> ipfsGatway <> "$1\">") note.heading 
      ]
      , if null note.children 
        then HH.span_ []
        else HH.ul_ $ note.children <#> renderNote ipfsGatway currentId (level + 1)
    ]


render :: forall cs m. State -> H.ComponentHTML Action cs m
render state =
  HH.div_
    [
    HH.ul_ $ state.renderNoteList <#> renderNote state.ipfsGatway state.currentId 1
    ]
    
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
 
handleAction :: forall cs o m . 
  MonadAff m =>  
  Now m =>
  ManageTopic m =>
  ManageIPFS m =>
  ManageNote m =>
  Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  ChangeEditID mb -> do 
    H.modify_ _ { currentId = mb}
    handleAction InitNote
    case mb of 
      Just id -> H.liftEffect $ autoFocus id
      Nothing -> pure unit
  New -> do
    hostId <- H.gets _.topicId 
    nowTime <- now
    uuid <- H.liftEffect UUID.genUUID
    let id = "note-" <> UUID.toString uuid
    let note = {
      id,
      heading: "",
      content: "",
      hostType: "topic",
      hostId,
      created: nowTime,
      updated: nowTime,
      parentId: "",
      childrenIds: []
    }
    void $ addNote note
    handleAction $ ChangeEditID $ Just id
  Submit noteId note->  do
    nowTime <- now
    void $ updateNoteById noteId { heading: note, updated: nowTime }
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
    ipfsGatway <- getIpfsGatewayPrefix
    H.modify_ _ { ipfsGatway = ipfsGatway}
  InitNote -> do
    topicId <- H.gets _.topicId
    notes <- getAllNotesByHostId topicId
    if null notes 
      then handleAction New 
      else do 
        let nodes = logAny $ noteToTree notes ""
        H.modify_  _ { 
          noteList = notes 
          , renderNoteList = nodes
        }
  ClickNote mev nid -> do
    H.liftEffect $ stopPropagation $ ME.toEvent mev
    handleAction $ Edit nid 
  Delete noteId -> do
    void $ deleteNote noteId
    handleAction $ ChangeEditID $ Nothing
  Indent id -> do
    notes <- H.gets _.noteList 
    let pid = searchPrevNoteId notes id
    case pid of
      Nothing -> pure unit
      Just pid' -> do
        void $ updateNoteById id { parentId: pid' }
        handleAction InitNote
        -- log $ "indent " <> id <> "+++++++" <> pid'
    pure unit
  HandleKeyDown id kbe 
    | KE.key kbe == "Enter" -> do 
      H.liftEffect $ preventDefault $ KE.toEvent kbe
    | KE.key kbe == "Tab" -> do 
      H.liftEffect $ preventDefault $ KE.toEvent kbe
    | otherwise -> pure unit
  
  HandleKeyUp id kbe 
    | KE.key kbe == "Enter" -> do 
      H.liftEffect $ preventDefault $ KE.toEvent kbe
      handleAction New
    | KE.key kbe == "Tab" -> do
      handleAction $ Indent id 
      pure unit
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
initialState { context, input } = { 
  topicId: input.topicId,
  currentId: Nothing,
  ipfsGatway: "https://dweb.link/ipfs/",
  collFile : context.collFile,
  ipfs : context.ipfs,
  noteList : [],
  renderNoteList: []
  }

subscriptPaste :: forall m. MonadAff m => Maybe IPFS -> m (HS.Emitter Action)
subscriptPaste ipfs = do
  { emitter, listener } <- H.liftEffect HS.create
  _ <- H.liftEffect $ addPasteListenner fromMaybe ipfs (\path -> HS.notify listener $ SubmitIpfs path)
  pure emitter

component :: forall q o m.  
  MonadAff m => 
  MonadStore LS.Action LS.Store m => 
  Now m =>
  ManageIPFS m =>
  ManageTopic m =>
  ManageNote m =>
  H.Component q Input o m
component = connect selectAll $ H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval { 
        handleAction = handleAction
      , initialize = Just InitComp
      , receive = Just <<< Receive
      }
    }