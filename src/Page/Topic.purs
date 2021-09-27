module LinkNote.Page.Topic where

import Prelude

import Control.Alternative ((<|>))
import Control.Monad.Error.Class (class MonadThrow, throwError)
import Control.Monad.State (class MonadState, modify_)
import Data.Array (cons, elem, elemIndex, filter, findIndex, index, mapWithIndex, null, sortWith)
import Data.Array as Array
import Data.Array.NonEmpty (NonEmptyArray, fromArray, init, last, snoc', toArray, uncons, updateAt)
import Data.Array.NonEmpty as NArray
import Data.Foldable (length)
import Data.Maybe (Maybe(..), fromMaybe, fromMaybe', isNothing)
import Data.String (splitAt)
import Data.String.Regex (Regex, replace, replace', test)
import Data.String.Regex.Flags (global, noFlags)
import Data.String.Regex.Unsafe (unsafeRegex)
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Exception (Error, error)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties (style)
import Halogen.HTML.Properties as HP
import Halogen.Store.Connect (Connected, connect)
import Halogen.Store.Monad (class MonadStore)
import Halogen.Store.Select (selectAll)
import Halogen.Subscription as HS
import Html.Renderer.Halogen as RH
import IPFS (IPFS)
import LinkNote.Capability.LogMessages (class LogMessages, logAnyM, logDebug)
import LinkNote.Capability.ManageFile (class ManageFile, addFile)
import LinkNote.Capability.ManageHTML (class ManageHTML, getCaretInfo)
import LinkNote.Capability.ManageIPFS (class ManageIPFS, getIpfsGatewayPrefix)
import LinkNote.Capability.Now (class Now, now)
import LinkNote.Capability.Resource.Note (class ManageNote, createTopicNote, deleteNote, getAllNotesByHostId, updateNoteById)
import LinkNote.Capability.Resource.Topic (class ManageTopic, getTopic, getTopics, updateTopicById)
import LinkNote.Capability.UUID (class UUID)
import LinkNote.Component.HTML.Utils (css)
import LinkNote.Component.Store as LS
import LinkNote.Component.Util (swapElem)
import LinkNote.Data.Data (Note, NoteId, Topic, TopicId, Point)
import Web.Clipboard.ClipboardEvent as CE
import Web.Event.Event (Event, currentTarget, preventDefault, stopPropagation, target)
import Web.Event.Internal.Types (EventTarget)
import Web.HTML.HTMLElement (getBoundingClientRect)
import Web.HTML.HTMLTextAreaElement as HTAE
import Web.UIEvent.KeyboardEvent as KE
import Web.UIEvent.MouseEvent as ME

foreign import doBlur :: EventTarget -> Effect Unit
foreign import innerText :: EventTarget -> Effect String
foreign import insertText :: String -> Effect Boolean 
foreign import autoFocus :: String -> Effect Unit 
foreign import unFocus :: String -> Effect Unit
newtype NoteNode = NoteNode {
  id :: NoteId
  , heading :: String
  , children :: Array NoteNode
  , parentId :: NoteId
  , path :: NonEmptyArray Int
}
type State = { 
    topic :: Topic
    , currentId :: Maybe String
    , noteList :: Array Note
    , renderNoteList :: Array NoteNode
    , ipfs :: Maybe IPFS
    , ipfsGatway :: String
    , visionNoteIds :: Array NoteId
    , popoverPosition :: Maybe Point
    , popoverList :: Array Topic
    , popoverCurrent :: Int
    , currentTextArea :: Maybe HTAE.HTMLTextAreaElement
    }

type Input = {
  topicId :: TopicId,
  topic :: Topic
}

type ConnectedInput = Connected LS.Store Input

type NodePath = NonEmptyArray Int

data Action
  = ChangeNoteText String String 
  | IgnorePaste CE.ClipboardEvent
  | HandleKeyUp NoteNode KE.KeyboardEvent
  | HandleKeyDown KE.KeyboardEvent
  | InitComp
  | Receive ConnectedInput
  | SubmitIpfs String
  | InsertTopicLink Topic
  | ClickNote ME.MouseEvent NoteId

foreign import addPasteListenner :: (forall a. a -> Maybe a -> a) -> Maybe IPFS -> (Function String (Effect Unit)) -> Effect Unit

type NoteSort = Array NoteId

throwTextError :: forall m a. MonadThrow Error m => String -> m a
throwTextError = throwError <<< error 

findNote :: forall m .
  MonadState State m =>
  MonadAff m => 
  MonadThrow Error m =>
  String -> m Note
findNote id = do 
  notes <- H.gets _.noteList
  fromJust' $ Array.find (\n -> n.id == id) notes 

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


fromJust' :: forall a m. MonadThrow Error m => Maybe a -> m a
fromJust' = case _ of
  Just x -> pure x 
  Nothing -> throwError $ error $ "出现未预期的Nothing"

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
regFileLink = unsafeRegex "\\(\\(file-(.*?)\\)\\)" global

regLink :: Regex
regLink = unsafeRegex "\\[\\[([^\\|\\[\\]]+?)(\\|([^\\|\\[\\]]+?))?\\]\\]" global

regLinkStart :: Regex
regLinkStart = unsafeRegex "\\[\\[$" noFlags

isStartLinkInput :: String -> Boolean
isStartLinkInput = test regLinkStart

linkStr :: String -> String -> String
linkStr id name = "<a class=\"text-pink-800\" onClick=\"event.stopPropagation();\" href=\"/#/topic/" <> id <> "\">" <> name <> "</a>"

replaceLink :: String -> String
replaceLink = replace' regLink re
  where 
    re _ [Just name, _,  Just id] = linkStr id name
    re _ [Just name, _, _ ]       = linkStr name name
    re _ xs                       = show xs

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
    , css "bg-gray-50 cursor-text"
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
              , HE.onValueInput \val -> ChangeNoteText note.id val
            -- , HE.onBlur \_ -> ChangeEditID Nothing
          ]
        ] 

      _ -> HH.div [ 
        HP.style contentStyle
      ] [ 
        RH.render_ $ replaceLink $ replace regFileLink ("<img src=\"" <> ipfsGatway <> "$1\">") note.heading 
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
    , case state.popoverPosition of
        Just p -> HH.div [ 
          css "fixed bg-blue-300 h-80 w-80", 
          style $ ("left: " <> show p.x <> "px; top: " <> show p.y <> "px;") ] [ 
            HH.ul_ $ mapWithIndex (\idx topic -> HH.li [ HE.onClick \_ -> InsertTopicLink topic, css $ if state.popoverCurrent == idx then "bg-red-500" else "" ] [HH.text topic.name]) state.popoverList 
          ]
        Nothing -> HH.span_ []
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
  UUID m =>
  ManageTopic m =>
  ManageIPFS m =>
  ManageNote m =>
  LogMessages m =>
  ManageHTML m =>
  ManageFile m =>
  MonadThrow Error m =>
  Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of

  InsertTopicLink topic -> do
    -- void $ addFile { cid: path,  id: fileId, mime: "", type: "" }
    let appendText = "[[" <> topic.name <> "|" <> topic.id <> "]]"
    insertLinkToNote appendText

  ChangeNoteText noteId note ->  do
    nowTime <- now
    void $ updateNoteById noteId { heading: note, updated: nowTime }
    -- initNote
  SubmitIpfs path -> do
    let fileId = "file-" <> path
    void $ addFile { cid: path,  id: fileId, mime: "", type: "" }
    let appendText = "((" <> fileId <> "))"
    void $ H.liftEffect $ insertText appendText
  InitComp -> do
    logDebug "初始化组件"
    initNote
    maybeIpfs <- H.gets _.ipfs
    _ <- H.subscribe =<< subscriptPaste maybeIpfs
    ipfsGatway <- getIpfsGatewayPrefix
    H.modify_ _ { ipfsGatway = ipfsGatway}

  ClickNote mev nid -> do
    H.liftEffect $ stopPropagation $ ME.toEvent mev
    changeEditID $ Just nid
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
          unIndent note.id note.path
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

          moveNoteToDown
          where
            moveNoteToDown = do
              let path = note.path
              nodes <- H.gets _.renderNoteList
              topic <- H.gets _.topic
              let parentNode = parentPath path >>= look nodes
              let mbPlen = case parentNode of 
                            (Just (NoteNode n)) -> Just $ length n.children
                            Nothing  -> Just $ length topic.noteIds
              let mbPpath = parentPath path
              let currentIdx = last path
              let func = \arr -> fromMaybe arr (swapElem currentIdx (currentIdx + 1) arr)
              case mbPlen of 
                (Just len) | currentIdx < len - 1 -> updateSortByPpath mbPpath func
                _ -> pure unit 
              initNote
              pure unit
        _ -> pure unit
    | KE.altKey kbe -> do
      pure unit
    | KE.metaKey kbe -> do
      pure unit
    | KE.ctrlKey kbe -> do 
      pure unit
    | (not KE.shiftKey kbe) && (not KE.ctrlKey kbe) && (not KE.altKey kbe) && (not KE.metaKey kbe)-> do -- 没有任何按键修饰符
      popoverPosition <- H.gets _.popoverPosition            
      case KE.key kbe, popoverPosition of
        "Enter", Just _ -> do 
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          idx <- H.gets _.popoverCurrent
          list <- H.gets _.popoverList
          let topic' = index list idx
          case topic' of 
            Nothing -> insertLinkToNote $ "[[" <> "" <> "]]"
            Just topic -> handleAction $ InsertTopicLink topic
        "Enter", _ -> do 
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          newNote note.parentId insertIdx
          where 
            insertIdx = 1 + last note.path
        "Tab", _ -> do
          H.liftEffect $ stopPropagation $ KE.toEvent kbe
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          -- logDebug $ "缩进元素的path为" <> show note.path
          indent note.id note.path
        "Escape", _ -> do 
          changeEditID Nothing
          let maybeTarget = currentTarget $ KE.toEvent kbe
          case maybeTarget of
            Just target -> do 
              H.liftEffect $ doBlur target
            Nothing -> pure unit
        "ArrowUp", Just _ -> do 
          popoverCurrent <- H.gets _.popoverCurrent
          if popoverCurrent == -1 
          then pure unit
          else H.modify_ _ { popoverCurrent = popoverCurrent - 1}
        "ArrowUp", _ -> do 
          ids <- H.gets _.visionNoteIds
          let prevId = visionPrevId ids note.id
          case prevId of
            (Just id) -> changeEditID $ Just id
            _ -> pure unit
        "ArrowDown", Just _ -> do 
          popoverCurrent <- H.gets _.popoverCurrent
          list <- H.gets _.popoverList
          if popoverCurrent == (length list) - 1
          then pure unit
          else H.modify_ _ { popoverCurrent = popoverCurrent + 1}
        "ArrowDown", _ -> do 
          ids <- H.gets _.visionNoteIds
          let nextId = visionNextId ids note.id
          case nextId of
            (Just id) -> changeEditID $ Just id
            _ -> pure unit
        "Backspace", _ -> do 
          maybeText <- H.liftEffect $ getTextFromEvent $ KE.toEvent kbe
          case maybeText of 
            Nothing -> pure unit
            Just text 
              | "" == text -> delete note.id 
              | otherwise -> pure unit 
        "[", _ -> do 
          caret <- getCaretInfo
          case caret of
            (Just caret') | isStartLinkInput caret'.beforeText -> do
              r <- liftEffect $ getBoundingClientRect caret'.element
              topics <- getTopics
              let mayArea = HTAE.fromEventTarget =<< (target $ KE.toEvent kbe)
              logAnyM $ (target $ KE.toEvent kbe)
              H.modify_ _ { 
                popoverPosition = Just {x: r.left , y: r.bottom}
                , popoverList = topics 
                , currentTextArea = mayArea
                , popoverCurrent = -1
              }
            _ -> pure unit
        _, _ -> pure unit
    | otherwise -> pure unit 
  IgnorePaste ev -> H.liftEffect $ preventDefault $ CE.toEvent ev
  Receive input -> do
    H.put $ initialState input
    handleAction InitComp
  where
    autoFoucsCurrentArea = do
      maybeId <- H.gets _.currentId 
      H.liftEffect $ autoFocus $ fromMaybe "dummy" maybeId
    updateSortByPpath ppath func = do
      nodes <- H.gets _.renderNoteList
      case ppath of
        Just path -> do 
          let parentNode' = look nodes path
          case parentNode' of
            Just (NoteNode parentNode) -> do
              updateSortInParent parentNode.id func
            Nothing -> pure unit 
        Nothing -> updateSortInParent "" func
      initNote
    updateSortInParent pid updateFunc = do
      if (pid == "") 
      then do
        topic <- H.gets _.topic
        let noteIds = Array.nubEq $ updateFunc topic.noteIds
        void $ updateTopicById topic.id { noteIds }
      else do
        notes <- H.gets _.renderNoteList        
        (NoteNode pNode) <- fromJust' $ findNode pid notes
        let prevChildIds = pNode.children <#> \(NoteNode n) -> n.id
        let childrenIds = Array.nubEq $ updateFunc prevChildIds
        void $ updateNoteById pid { childrenIds }
    insertSortInParent pid id idx = do
      updateSortInParent pid \ids -> fromMaybe' (\_ -> Array.snoc ids id) (Array.insertAt idx id ids)
    deleteSortInParent pid id = do
      updateSortInParent pid $ Array.delete id
    moveSort noteId sourcePid targetPid targetIdx = do 
      insertSortInParent targetPid noteId targetIdx
      deleteSortInParent sourcePid noteId    
    initNote = do
      logDebug "初始化State"
      topic' <- H.gets _.topic
      let topicId = topic'.id
      topicMaybe <- getTopic topicId
      when (isNothing topicMaybe) do
        throwError $ error "更新Topic错误"
      let topic = fromMaybe topic' topicMaybe
      notes <- getAllNotesByHostId topicId
      let nodes = noteToTree notes "" [] topic.noteIds
      let ids = treeToIdList nodes
      if null nodes 
        then newNote "" 0
        else do 
          H.modify_  _ { 
            noteList = notes 
            , topic = topic
            , renderNoteList = nodes
            , visionNoteIds = ids
          }
          logDebug "笔记列表已刷新"
          handdleAutoFoucs
    newNote pid idx = do
      topic <- H.gets _.topic 
      note' <- createTopicNote topic.id pid ""
      logDebug $ "增加一个新的Note，pid为" <> (show note')
      case note' of
        Nothing -> throwError $ error "增加note失败"
        Just note -> do
          insertSortInParent pid note.id idx
          changeEditID $ Just note.id
    handdleAutoFoucs = do
      maybeId <- H.gets _.currentId 
      id <- fromJust' (maybeId <|> pure "dummy")
      H.liftEffect $ autoFocus id
    changeEditID mb = do 
      H.modify_ _ { currentId = mb
                  , popoverPosition = Nothing
                  , popoverList = [] }
      initNote
    delete noteId = do
      notes <- H.gets _.noteList
      note <- fromJust' $ Array.find (\n -> n.id == noteId) notes
      updateSortInParent note.parentId $ Array.delete noteId
      void $ deleteNote noteId
      changeEditID Nothing

    indent id path = do
      nodes <- H.gets _.renderNoteList
      note <- findNote id
      NoteNode prevNode <- fromJust' $ prevPath path >>= look nodes
      let len = length prevNode.children
      let source = note.parentId
      let target = prevNode.id
      
      void $ updateNoteById id { parentId: target }

      -- logDebug $ "上一个节点的子元素个数为  " <> show len
      moveSort id source target len
      initNote
    unIndent id path = do
      nodes <- H.gets _.renderNoteList
      note <- findNote id
      NoteNode parentNode <- fromJust' $ parentPath path >>= look nodes
      let source = note.parentId
      let target = parentNode.parentId 
      void $ updateNoteById id { parentId: parentNode.parentId }
      moveSort id source target toTargetIdx
      initNote
        where 
          toTargetIdx :: Int 
          toTargetIdx =  case lastSecond path of 
            Nothing -> 0
            Just idx -> 1 + idx
    insertLinkToNote appendText = do
      textarea <- H.gets _.currentTextArea 
      case textarea of
        Just ta -> do
          insertPoint <- liftEffect $ HTAE.selectionStart ta
          val  <- liftEffect $ HTAE.value ta
          void $ H.liftEffect $ insertText appendText
          let r = splitAt insertPoint val
          let newBefore = replace regLinkStart appendText r.before 
          H.liftEffect $ HTAE.setValue (newBefore <> r.after) ta
          modify_ _ {
            popoverPosition = Nothing
            , popoverList = [] 
          }
          autoFoucsCurrentArea
        _ -> pure unit
initialState :: ConnectedInput-> State
initialState { context, input } = { 
  currentId: Nothing
  , topic: input.topic
  , ipfsGatway: "https://dweb.link/ipfs/"
  , ipfs : context.ipfs
  , noteList : []
  , renderNoteList: []
  , visionNoteIds: []
  , popoverPosition: Nothing
  , popoverList: []
  , popoverCurrent: -1
  , currentTextArea : Nothing
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
  UUID m =>
  ManageIPFS m =>
  LogMessages m =>
  ManageTopic m =>
  ManageNote m =>
  ManageFile m =>
  ManageHTML m =>
  MonadThrow Error m =>
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