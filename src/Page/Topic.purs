module LinkNote.Page.Topic where

import Prelude

import Data.Array (cons, elemIndex, filter, findIndex, index, mapWithIndex, null)
import Data.Array as Array 
import Data.Array.NonEmpty (NonEmptyArray, fromArray, init, last, length, toArray, uncons, updateAt, snoc')
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String.Regex (Regex, replace)
import Data.String.Regex.Flags (global)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.UUID as UUID
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
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
  , parentId :: NoteId
  , path :: NonEmptyArray Int
}

type State = { 
    topicId :: TopicId,
    currentId :: Maybe String,
    collFile :: RxCollection File,
    noteList :: Array Note,
    renderNoteList :: Array NoteNode,
    ipfs :: Maybe IPFS,
    ipfsGatway :: String
    , visionNoteIds :: Array NoteId
    }

type Input = {
  topicId :: TopicId
}

type ConnectedInput = Connected LS.Store Input

type NodePath = NonEmptyArray Int

data Action
  = Submit String String 
  | InitNote 
  | New NoteId
  | IgnorePaste CE.ClipboardEvent
  | HandleKeyUp NoteNode KE.KeyboardEvent
  | HandleKeyDown KE.KeyboardEvent
  | InitComp
  | Receive ConnectedInput
  | SubmitIpfs String
  | Delete String 
  | Edit String
  | Indent NoteId NodePath
  | UnIndent NoteId NodePath
  | EditNote Event String 
  | ClickNote ME.MouseEvent NoteId
  | ChangeEditID (Maybe String)


foreign import addPasteListenner :: (forall a. a -> Maybe a -> a) -> Maybe IPFS -> (Function String (Effect Unit)) -> Effect Unit


noteToTree :: Array Note -> NoteId -> Array Int -> Array NoteNode
noteToTree notelist parentId parentP = mapWithIndex  toTree filterdList
  where
    filterdList = filter (\note -> note.parentId == parentId) notelist
    toTree idx note = NoteNode {
      id: note.id
      , heading: note.heading
      , parentId: note.parentId
      , path : snoc' parentP idx
      , children: noteToTree notelist note.id $ toArray $ snoc' parentP idx
    }

treeToIdList :: Array NoteNode -> Array NoteId
treeToIdList nodes = do
  node' <- nodes
  let (NoteNode  node) = node' 
  cons node.id $ treeToIdList node.children

visionPrevId :: Array NoteId -> NoteId -> Maybe NoteId
visionPrevId ids id = do
  currIdx <- elemIndex id ids 
  if currIdx == 0 
    then Nothing
    else ids `index` (currIdx - 1)

visionNextId :: Array NoteId -> NoteId -> Maybe NoteId
visionNextId ids id = do
  currIdx <- elemIndex id ids
  if currIdx == (Array.length ids) - 1
    then Nothing
    else ids `index` (currIdx + 1)

searchPrevNoteId :: Array Note -> NoteId -> Maybe NoteId
searchPrevNoteId [] _ = Nothing
searchPrevNoteId [_] _ = Nothing
searchPrevNoteId notes id = do
  idx <- findIndex (\note -> note.id == id) notes
  if idx == 0 then Nothing else do
    note <- index notes $ idx - 1
    pure note.id

look :: Array NoteNode -> NodePath -> Maybe NoteNode
look nodes path = do
  let us = uncons path
  current@(NoteNode curr) <- index nodes us.head 
  if null us.tail 
    then pure current
    else do
      tail <- fromArray us.tail
      look curr.children tail

parentPath :: NodePath -> Maybe NodePath
parentPath path = do
  let len = length path
  if len == 1 
    then Nothing
    else fromArray $ init path

prevPath :: NodePath -> Maybe NodePath
prevPath path = do
  let las = last path
  let lasInx = (length path) - 1
  if las == 0 
    then Nothing
    else updateAt lasInx (las - 1) path

regFileLink :: Regex
regFileLink = unsafeRegex "\\[\\[file-(.*?)\\]\\]" global

renderNote :: forall  a. String -> Maybe String -> Int ->  NoteNode -> HH.HTML a Action
renderNote ipfsGatway currentId level noteNode@(NoteNode note)  = 
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
        , HE.onKeyUp \kbe -> HandleKeyUp noteNode kbe 
        , HE.onKeyDown \kbe -> HandleKeyDown kbe
        , HE.onPaste IgnorePaste
        , HE.onValueInput \val -> Submit note.id val
        , css "bg-gray-100"
        -- , HE.onBlur \_ -> ChangeEditID Nothing
      ]

      _ -> HH.div [ 
        HP.class_ $ ClassName "head bg-gray-50"
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
  New pid -> do
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
      parentId: pid,
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
      then handleAction $ New ""
      else do 
        let nodes = noteToTree notes "" []
        let ids = treeToIdList nodes
        H.modify_  _ { 
          noteList = notes 
          , renderNoteList = nodes
          , visionNoteIds = ids
        }
  ClickNote mev nid -> do
    H.liftEffect $ stopPropagation $ ME.toEvent mev
    handleAction $ Edit nid 
  Delete noteId -> do
    void $ deleteNote noteId
    handleAction $ ChangeEditID $ Nothing
  Indent id path -> do
    nodes <- H.gets _.renderNoteList
    let prevNode = prevPath path >>= look nodes
    case prevNode of
      Nothing -> pure unit
      Just (NoteNode node) -> do
        void $ updateNoteById id { parentId: node.id }
        handleAction InitNote
    pure unit
  UnIndent id path -> do
    nodes <- H.gets _.renderNoteList
    let parentNode = parentPath path >>= look nodes
    case parentNode of
      Nothing -> pure unit
      Just (NoteNode node) -> do
        void $ updateNoteById id { parentId: node.parentId }
        handleAction InitNote
    pure unit
  HandleKeyDown kbe 
    | KE.key kbe == "Enter" -> do 
      H.liftEffect $ preventDefault $ KE.toEvent kbe
    | KE.key kbe == "Tab" -> do 
      H.liftEffect $ preventDefault $ KE.toEvent kbe
    | otherwise -> pure unit
  
  HandleKeyUp (NoteNode note) kbe 
    | KE.shiftKey kbe && KE.key kbe == "Tab" -> do
      handleAction $ UnIndent note.id note.path
    | KE.key kbe == "Enter" -> do 
      H.liftEffect $ preventDefault $ KE.toEvent kbe
      handleAction $ New note.parentId
    | KE.key kbe == "Tab" -> do
      handleAction $ Indent note.id note.path
    | KE.key kbe == "Escape" -> do 
        handleAction $ ChangeEditID Nothing
        let maybeTarget = currentTarget $ KE.toEvent kbe
        case maybeTarget of
          Just target -> do 
            H.liftEffect $ doBlur target
          Nothing -> pure unit

    | KE.key kbe == "ArrowUp" -> do 
      ids <- H.gets _.visionNoteIds
      let prevId = visionPrevId ids note.id
      case prevId of
        (Just id) -> handleAction $ ChangeEditID $ Just id
        _ -> pure unit
    | KE.key kbe == "ArrowDown" -> do 
      ids <- H.gets _.visionNoteIds
      let nextId = visionNextId ids note.id
      case nextId of
        (Just id) -> handleAction $ ChangeEditID $ Just id
        _ -> pure unit
    | KE.key kbe == "Backspace" -> do 
      maybeText <- H.liftEffect $ getTextFromEvent $ KE.toEvent kbe

      case maybeText of 
        Nothing -> pure unit
        Just text 
          | "" == text -> handleAction $ Delete note.id 
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
      isUpdate (Just x) (Just y) = not $ unsafeRefEq (x) (y)
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
  , visionNoteIds: []
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