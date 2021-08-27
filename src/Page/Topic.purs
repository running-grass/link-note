module LinkNote.Page.Topic where

import Prelude

import Control.Alternative ((<|>))
import Control.Monad.State (class MonadState)
import Data.Array (cons, elem, elemIndex, filter, findIndex, index, mapWithIndex, null, sortWith)
import Data.Array as Array
import Data.Array.NonEmpty (NonEmptyArray, fromArray, init, last, snoc', toArray, uncons, updateAt)
import Data.Array.NonEmpty as NArray
import Data.Foldable (length)
import Data.Maybe (Maybe(..), fromMaybe, fromMaybe')
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
import LinkNote.Capability.LogMessages (class LogMessages, logAny, logDebug)
import LinkNote.Capability.ManageFile (class ManageFile, addFile)
import LinkNote.Capability.ManageIPFS (class ManageIPFS, getIpfsGatewayPrefix)
import LinkNote.Capability.Now (class Now, now)
import LinkNote.Capability.Resource.Note (class ManageNote, addNote, deleteNote, getAllNotesByHostId, updateNoteById)
import LinkNote.Capability.Resource.Topic (class ManageTopic, getTopic, updateTopicById)
import LinkNote.Component.HTML.Utils (css)
import LinkNote.Component.Store as LS
import LinkNote.Component.Util (liftMaybe, swapElem)
import LinkNote.Data.Data (Note, NoteId, TopicId, Topic)
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

-- derive newtype instance Eq NoteNode

type State = { 
    topicId :: TopicId,
    topic :: Maybe Topic,
    currentId :: Maybe String,
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
  | AutoFoucs
  | New NoteId Int -- int 为在父元素中的索引
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
  | UpdateSortInParent String (NoteSort -> NoteSort)
  | DeleteSortInParent String NoteId
  | InsertSortInParent String NoteId Int -- maybe noteid为插入到哪个元素后面
  | MoveSort NoteId String String Int -- 把noteid从哪里到哪里

foreign import addPasteListenner :: (forall a. a -> Maybe a -> a) -> Maybe IPFS -> (Function String (Effect Unit)) -> Effect Unit

type NoteSort = Array NoteId

findNote :: forall m .
  MonadState State m =>
  MonadAff m => 
  String -> m Note
findNote id = do 
  notes <- H.gets _.noteList
  liftMaybe $ Array.find (\n -> n.id == id) notes

noteToTree :: Array Note -> NoteId -> Array Int -> NoteSort -> Array NoteNode
noteToTree notelist parentId parentP sortIds =  mapWithIndex toTree $ sortChild filterdList
  where
    filterdList :: Array Note
    filterdList = filter (\note -> note.parentId == parentId && (Array.elem note.id sortIds) ) notelist
    toTree idx note = NoteNode {
      id: note.id
      , heading: note.heading
      , parentId: note.parentId
      , path : snoc' parentP idx
      , children: noteToTree notelist note.id (toArray $ snoc' parentP idx) note.childrenIds
    }
    sortChild :: Array Note -> Array Note
    sortChild = sortWith \node -> fromMaybe (length sortIds) (elemIndex node.id sortIds)    

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

flatten_ :: NoteNode -> Array NoteNode 
flatten_ node@(NoteNode node_) = Array.cons node (Array.concatMap flatten_ node_.children)

flatten :: Array NoteNode -> Array NoteNode 
flatten nodes = Array.concatMap flatten_ nodes

findNode :: NoteId -> Array NoteNode -> Maybe NoteNode
findNode id nodes = Array.find (\(NoteNode n) -> n.id == id) $ flatten nodes


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

lastSecond :: forall a. NonEmptyArray a -> Maybe a
lastSecond f = NArray.index f $ len - 2
  where 
    len = length f

noteWrap :: String
noteWrap = """
position: relative;
width: 100%;
"""

textareaStyle :: String
textareaStyle = """
    resize:none;
    height: 100%;
    position: absolute;
    left: 0;
    top: 0;
    background-color: transparent;
"""

notePlaceholder :: String
notePlaceholder = """
visibility: hidden;
"""

contentStyle :: String
contentStyle =  """
    min-height: 30px;
    border: 0;
    width: 100%;
    font-family:PingFangSC-Regular,PingFang SC;
    display: block;
    font-size: 14px;
    color: #333333;
    line-height: 1.3;
    padding: 5px 0;
    overflow:hidden;
    white-space: pre-wrap;
    word-wrap: break-word;
    word-break: break-word;
"""
renderNote :: forall  a. String -> Maybe String -> Int ->  NoteNode -> HH.HTML a Action
renderNote ipfsGatway currentId level noteNode@(NoteNode note)  = 
  HH.li [ 
    HP.id note.id 
    , HE.onClick \ev -> ClickNote ev note.id 
    , css "bg-gray-50"
    , HP.style "min-height: 30px;"
    ] 
    [
      case currentId of 
      Just id | id == note.id -> 
        HH.div [
          css "bg-gray-200"
          , HP.style noteWrap
          ] [
            HH.pre [
              HP.style $ notePlaceholder <> contentStyle
              ] [ HH.text note.heading ]
            , HH.textarea [
              HP.value note.heading
              , css "focus:ring-0"
              , HP.style $ textareaStyle <> contentStyle
              , HE.onKeyUp \kbe -> HandleKeyUp noteNode kbe 
              , HE.onKeyDown \kbe -> HandleKeyDown kbe
              , HE.onPaste IgnorePaste
              , HE.onValueInput \val -> Submit note.id val
            -- , HE.onBlur \_ -> ChangeEditID Nothing
          ]
        ] 

      _ -> HH.div [ 
        HP.style "word-break: break-all;"
      ] [ 
        RH.render_ $ replace regFileLink ("<img src=\"" <> ipfsGatway <> "$1\">") note.heading 
      ]

      , if null note.children 
        then HH.span_ []
        else HH.ul [css $ "list-disc pl-6"] $ note.children <#> renderNote ipfsGatway currentId (level + 1)
    ]


render :: forall cs m. State -> H.ComponentHTML Action cs m
render state =
  HH.div_
    [
    HH.ul [css "list-disc pl-6"] $ state.renderNoteList <#> renderNote state.ipfsGatway state.currentId 1
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
  LogMessages m =>
  ManageFile m =>
  Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  ChangeEditID mb -> do 
    H.modify_ _ { currentId = mb}
    handleAction InitNote
  AutoFoucs -> do
    maybeId <- H.gets _.currentId 
    id <- liftMaybe (maybeId <|> pure "dummy")
    -- logDebug $ "编辑笔记" <> id
    H.liftEffect $ autoFocus id
  New pid idx -> do
    logDebug $ "增加一个新的Note，id为" <> pid
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
    handleAction $ InitNote
    handleAction $ InsertSortInParent pid id idx
    handleAction $ ChangeEditID $ Just id
    
  UpdateSortInParent pid updateFunc -> do
    if (pid == "") 
      then do
        topic <- liftMaybe =<< H.gets _.topic
        let noteIds = Array.nubEq $ updateFunc topic.noteIds
        void $ updateTopicById topic.id { noteIds }
      else do
        notes <- H.gets _.renderNoteList        
        (NoteNode pNode) <- liftMaybe $ findNode pid notes
        let prevChildIds = pNode.children <#> \(NoteNode n) -> n.id
        let childrenIds = Array.nubEq $ updateFunc prevChildIds
        void $ updateNoteById pid { childrenIds }
  InsertSortInParent pid id idx -> do
    handleAction $ UpdateSortInParent pid \ids -> fromMaybe' (\_ -> Array.snoc ids id) (Array.insertAt idx id ids)
  DeleteSortInParent pid id -> do
    handleAction $ UpdateSortInParent pid $ Array.delete id
  MoveSort noteId sourcePid targetPid targetIdx -> do 
    handleAction $ InsertSortInParent targetPid noteId targetIdx
    handleAction $ DeleteSortInParent sourcePid noteId
  Submit noteId note ->  do
    nowTime <- now
    void $ updateNoteById noteId { heading: note, updated: nowTime }
    handleAction InitNote
  SubmitIpfs path -> do
    let fileId = "file-" <> path
    void $ addFile { cid: path,  id: fileId, mime: "", type: "" }
    let appendText = "[[" <> fileId <> "]]"
    void $ H.liftEffect $ insertText appendText
  InitComp -> do
    logDebug "初始化组件"
    handleAction InitNote
    maybeIpfs <- H.gets _.ipfs
    _ <- H.subscribe =<< subscriptPaste maybeIpfs
    ipfsGatway <- getIpfsGatewayPrefix
    H.modify_ _ { ipfsGatway = ipfsGatway}
  InitNote -> do
    logDebug "初始化State"
    topicId <- H.gets _.topicId
    topic <- getTopic topicId

    topic_ <- liftMaybe topic
    logDebug $ "读取到topic " <> topic_.name
    H.modify_  _ { 
      topic = Just topic_
    }
    notes <- getAllNotesByHostId topicId
    if null notes 
      then handleAction $ New "" 0
      else do 
        let nodes = noteToTree notes "" [] topic_.noteIds
        let ids = treeToIdList nodes
        H.modify_  _ { 
          noteList = notes 
          , renderNoteList = nodes
          , visionNoteIds = ids
        }
        logDebug "笔记列表已刷新"
        handleAction AutoFoucs

  ClickNote mev nid -> do
    H.liftEffect $ stopPropagation $ ME.toEvent mev
    handleAction $ Edit nid 
  Delete noteId -> do
    notes <- H.gets _.noteList
    note <- liftMaybe $ Array.find (\n -> n.id == noteId) notes
    handleAction $ UpdateSortInParent note.parentId $ Array.delete noteId
    void $ deleteNote noteId
    handleAction $ ChangeEditID $ Nothing
  
  Indent id path -> do
    nodes <- H.gets _.renderNoteList
    note <- findNote id
    NoteNode prevNode <- liftMaybe $ prevPath path >>= look nodes
    let len = length prevNode.children
    let source = note.parentId
    let target = prevNode.id
    
    void $ updateNoteById id { parentId: target }

    -- logDebug $ "上一个节点的子元素个数为  " <> show len
    handleAction $ MoveSort id source target len
    handleAction InitNote
  UnIndent id path -> do
    nodes <- H.gets _.renderNoteList
    note <- findNote id
    NoteNode parentNode <- liftMaybe $ parentPath path >>= look nodes
    let source = note.parentId
    let target = parentNode.parentId 
    void $ updateNoteById id { parentId: parentNode.parentId }
    handleAction $ MoveSort id source target toTargetIdx
    handleAction InitNote
      where 
        toTargetIdx :: Int 
        toTargetIdx =  case lastSecond path of 
          Nothing -> 0
          Just idx -> 1 + idx
  HandleKeyDown kbe 
    | elem (KE.key kbe) ["Tab", "Enter", "ArrowUp", "ArrowDown"] -> do 
      H.liftEffect $ stopPropagation $ KE.toEvent kbe
      H.liftEffect $ preventDefault $ KE.toEvent kbe
    | otherwise -> pure unit
  
  HandleKeyUp (NoteNode note) kbe 
    -- 按下Shift修饰键的情况
    | KE.shiftKey kbe -> do
      case KE.key kbe of
        -- 反缩进
        "Tab" -> do 
          H.liftEffect $ stopPropagation $ KE.toEvent kbe
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          handleAction $ UnIndent note.id note.path
        -- 把当前标题向上移动
        "ArrowUp" -> do 
          H.liftEffect $ stopPropagation $ KE.toEvent kbe
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          let path = note.path
          let mbPid = parentPath path
          let currentIdx = last path
          let func = \arr -> fromMaybe arr (swapElem currentIdx (currentIdx - 1) arr)
          if currentIdx == 0 
            then pure unit
            else updateSortByPpath mbPid func 
        -- 把当前标题向下移动
        "ArrowDown" -> do
          H.liftEffect $ stopPropagation $ KE.toEvent kbe
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          let path = note.path
          nodes <- H.gets _.renderNoteList
          topic <- H.gets _.topic
          let parentNode = parentPath path >>= look nodes
          let mbPlen = case parentNode , topic of 
                        (Just (NoteNode n)) , _ -> Just $ length n.children
                        Nothing , (Just t) -> Just $ length t.noteIds
                        _ , _ -> Nothing
          let mbPpath = parentPath path
          let currentIdx = last path
          let func = \arr -> fromMaybe arr (swapElem currentIdx (currentIdx + 1) arr)
          case mbPlen of 
            (Just len) | currentIdx < len - 1 -> updateSortByPpath mbPpath func
            _ -> pure unit 
          handleAction InitNote
          pure unit
        _ -> pure unit
    | KE.altKey kbe -> do
      pure unit
    | KE.metaKey kbe -> do
      pure unit
    | KE.ctrlKey kbe -> do 
      pure unit
    | (not KE.shiftKey kbe) && (not KE.ctrlKey kbe) && (not KE.altKey kbe) && (not KE.metaKey kbe)-> do
      case KE.key kbe of
        "Enter" -> do 
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          handleAction $ New note.parentId insertIdx
          where 
            insertIdx = 1 + last note.path
        "Tab" -> do
          H.liftEffect $ stopPropagation $ KE.toEvent kbe
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          -- logDebug $ "缩进元素的path为" <> show note.path
          handleAction $ Indent note.id note.path
        "Escape" -> do 
          handleAction $ ChangeEditID Nothing
          let maybeTarget = currentTarget $ KE.toEvent kbe
          case maybeTarget of
            Just target -> do 
              H.liftEffect $ doBlur target
            Nothing -> pure unit
        "ArrowUp" -> do 
          ids <- H.gets _.visionNoteIds
          let prevId = visionPrevId ids note.id
          case prevId of
            (Just id) -> handleAction $ ChangeEditID $ Just id
            _ -> pure unit
        "ArrowDown" -> do 
          ids <- H.gets _.visionNoteIds
          let nextId = visionNextId ids note.id
          case nextId of
            (Just id) -> handleAction $ ChangeEditID $ Just id
            _ -> pure unit
        "Backspace" -> do 
          maybeText <- H.liftEffect $ getTextFromEvent $ KE.toEvent kbe
          case maybeText of 
            Nothing -> pure unit
            Just text 
              | "" == text -> handleAction $ Delete note.id 
              | otherwise -> pure unit 
        _ -> pure unit
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
  where
    updateSortByPpath ppath func = do
      nodes <- H.gets _.renderNoteList
      case ppath of
        Just path -> do 
          let parentNode' = look nodes path
          case parentNode' of
            Just (NoteNode parentNode) -> do
              handleAction $ UpdateSortInParent parentNode.id func
            Nothing -> pure unit 
        Nothing -> handleAction $ UpdateSortInParent "" func
      handleAction InitNote
initialState :: ConnectedInput-> State
initialState { context, input } = { 
  topicId: input.topicId,
  currentId: Nothing,
  topic: Nothing,
  ipfsGatway: "https://dweb.link/ipfs/",
  ipfs : context.ipfs,
  noteList : [],
  renderNoteList: []
  , visionNoteIds: []
  }

subscriptPaste :: forall m. 
  MonadAff m => 
  LogMessages m =>
  Now m =>
  Maybe IPFS -> m (HS.Emitter Action)
subscriptPaste ipfs = do
  { emitter, listener } <- H.liftEffect HS.create
  _ <- H.liftEffect $ addPasteListenner fromMaybe ipfs (\path -> HS.notify listener $ SubmitIpfs path)
  logDebug "绑定全局粘贴事件"
  pure emitter

component :: forall q o m.  
  MonadAff m => 
  MonadStore LS.Action LS.Store m => 
  Now m =>
  ManageIPFS m =>
  LogMessages m =>
  ManageTopic m =>
  ManageNote m =>
  ManageFile m =>
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