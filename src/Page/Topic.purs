module LinkNote.Page.Topic where

import Prelude

import Control.Alternative ((<|>))
import Control.Monad.Error.Class (class MonadThrow, throwError)
import Control.Monad.State (modify_)
import Data.Array (elem, elemIndex, filter, findIndex, fromFoldable, index, mapWithIndex, null, sortWith)
import Data.Array as Array
import Data.Array.NonEmpty (NonEmptyArray, last)
import Data.Array.NonEmpty as NArray
import Data.Foldable (length)
import Data.Foldable as Foldable
import Data.FoldableWithIndex (findWithIndex)
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
import LinkNote.Data.Tree as Tree
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
type State = { 
    topic :: Topic
    , noteForest :: Tree.Forest Note
    , currentId :: Maybe String
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

data Action
  = ChangeNoteText String String 
  | IgnorePaste CE.ClipboardEvent
  | HandleKeyUp (Tree.Tree Note) KE.KeyboardEvent
  | HandleKeyDown KE.KeyboardEvent
  | InitComp
  | Receive ConnectedInput
  | SubmitIpfs String
  | InsertTopicLink Topic
  | ClickNote ME.MouseEvent NoteId

foreign import addPasteListenner :: (forall a. a -> Maybe a -> a) -> Maybe IPFS -> (Function String (Effect Unit)) -> Effect Unit

type NoteSort = Array NoteId

noteToTree' :: Array Note -> NoteId -> NoteSort -> Tree.Forest Note
noteToTree' notelist parentId sortIds = Tree.Forest $ map toTree $ sortChild filterdList
  where
    filterdList :: Array Note
    filterdList = filter (\note -> note.parentId == parentId && (Array.elem note.id sortIds) ) notelist
    toTree note = Tree.Node note $ noteToTree' notelist note.id note.childrenIds
    sortChild :: Array Note -> Array Note
    sortChild = sortWith \node -> fromMaybe (length sortIds) (elemIndex node.id sortIds)    

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

fromJust' :: forall a m. MonadThrow Error m => Maybe a -> m a
fromJust' = case _ of
  Just x -> pure x 
  Nothing -> throwError $ error $ "出现未预期的Nothing"

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
renderNote :: forall  a. String -> Maybe String -> Int -> Tree.Tree Note  -> HH.HTML a Action
renderNote ipfsGatway currentId level noteTree@(Tree.Node note (Tree.Forest children))  = 
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
              , HE.onKeyUp \kbe -> HandleKeyUp noteTree kbe 
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

      , if null children 
        then HH.span_ []
        else HH.ul [css $ "list-disc pl-6"] $ children <#> renderNote ipfsGatway currentId (level + 1)
    ]


render :: forall cs m. State -> H.ComponentHTML Action cs m
render state =
  HH.div_
    [
    HH.ul [css "list-disc pl-6"] $ renderList state.noteForest
    , case state.popoverPosition of
        Just p -> HH.div [ 
          css "fixed bg-blue-300 h-80 w-80", 
          style $ ("left: " <> show p.x <> "px; top: " <> show p.y <> "px;") ] [ 
            HH.ul_ $ mapWithIndex (\idx topic -> HH.li [ HE.onClick \_ -> InsertTopicLink topic, css $ if state.popoverCurrent == idx then "bg-red-500" else "" ] [HH.text topic.name]) state.popoverList 
          ]
        Nothing -> HH.span_ []
    ]
  where 
    renderList (Tree.Forest tas) = tas <#> renderNote state.ipfsGatway state.currentId 1
    
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
  
  HandleKeyUp (Tree.Node note _) kbe 
    -- 按下Shift修饰键的情况
    | KE.shiftKey kbe -> do
      nodes <- H.gets _.noteForest 
      let path_ = findWithIndex (\_ d -> d.id == note.id) nodes <#> \r -> r.index
      case KE.key kbe, path_ of
        -- 反缩进
        "Tab",Just path' -> do 
          H.liftEffect $ stopPropagation $ KE.toEvent kbe
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          unIndent note path'
        -- 把当前标题向上移动
        "ArrowUp", Just path' -> do 
          H.liftEffect $ stopPropagation $ KE.toEvent kbe
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          let path = path'
          let mbPid = Tree.parentPath path
          let currentIdx = last path
          let func = \arr -> fromMaybe arr (swapElem currentIdx (currentIdx - 1) arr)
          if currentIdx == 0 
            then pure unit
            else updateSortByPpath mbPid func 
        -- 把当前标题向下移动
        "ArrowDown", Just path' -> do
          H.liftEffect $ stopPropagation $ KE.toEvent kbe
          H.liftEffect $ preventDefault $ KE.toEvent kbe

          moveNoteToDown
          where
            moveNoteToDown = do
              let path = path'
              notess <- H.gets _.noteForest
              topic <- H.gets _.topic
              let parentNode = Tree.parentPath path >>= Tree.look notess
              let mbPlen = case parentNode of 
                            (Just ta) -> Just $ Tree.childrenLenth ta
                            Nothing  -> Just $ length topic.noteIds
              let mbPpath = Tree.parentPath path
              let currentIdx = last path
              let func = \arr -> fromMaybe arr (swapElem currentIdx (currentIdx + 1) arr)
              case mbPlen of 
                (Just len) | currentIdx < len - 1 -> updateSortByPpath mbPpath func
                _ -> pure unit 
              initNote
              pure unit
        _, _ -> pure unit
    | KE.altKey kbe -> do
      pure unit
    | KE.metaKey kbe -> do
      pure unit
    | KE.ctrlKey kbe -> do 
      pure unit
    | (not KE.shiftKey kbe) && (not KE.ctrlKey kbe) && (not KE.altKey kbe) && (not KE.metaKey kbe)-> do -- 没有任何按键修饰符
      popoverPosition <- H.gets _.popoverPosition
      nodes <- H.gets _.noteForest 
      let path_ = findWithIndex (\_ d -> d.id == note.id) nodes <#> \r -> r.index
      case KE.key kbe, popoverPosition, path_ of
        "Enter", Just _, _ -> do 
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          idx <- H.gets _.popoverCurrent
          list <- H.gets _.popoverList
          let topic' = index list idx
          case topic' of 
            Nothing -> insertLinkToNote $ "[[" <> "" <> "]]"
            Just topic -> handleAction $ InsertTopicLink topic
        "Enter", _,Just path -> do 
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          newNote note.parentId insertIdx
          where 
            insertIdx = 1 + last path
        "Tab", _, Just path -> do
          H.liftEffect $ stopPropagation $ KE.toEvent kbe
          H.liftEffect $ preventDefault $ KE.toEvent kbe
          indent note path
        "Escape", _, _ -> do 
          changeEditID Nothing
          let maybeTarget = currentTarget $ KE.toEvent kbe
          case maybeTarget of
            Just target -> do 
              H.liftEffect $ doBlur target
            Nothing -> pure unit
        "ArrowUp", Just _, _ -> do 
          popoverCurrent <- H.gets _.popoverCurrent
          if popoverCurrent == -1 
          then pure unit
          else H.modify_ _ { popoverCurrent = popoverCurrent - 1}
        "ArrowUp", _, _ -> do 
          ids <- H.gets _.visionNoteIds
          let prevId = visionPrevId ids note.id
          case prevId of
            (Just id) -> changeEditID $ Just id
            _ -> pure unit
        "ArrowDown", Just _, _ -> do 
          popoverCurrent <- H.gets _.popoverCurrent
          list <- H.gets _.popoverList
          if popoverCurrent == (length list) - 1
          then pure unit
          else H.modify_ _ { popoverCurrent = popoverCurrent + 1}
        "ArrowDown", _, _ -> do 
          ids <- H.gets _.visionNoteIds
          let nextId = visionNextId ids note.id
          case nextId of
            (Just id) -> changeEditID $ Just id
            _ -> pure unit
        "Backspace", _, _ -> do 
          maybeText <- H.liftEffect $ getTextFromEvent $ KE.toEvent kbe
          case maybeText of 
            Nothing -> pure unit
            Just text 
              | "" == text -> delete note 
              | otherwise -> pure unit 
        "[", _, _ -> do 
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
        _, _, _ -> pure unit
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
      nodes <- H.gets _.noteForest
      case ppath of
        Just path -> do 
          let parentNode' = Tree.look' nodes path
          case parentNode' of
            Just parentNode -> do
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
        notess <- H.gets _.noteForest
        sublings <- fromJust' $ Tree.findChildrenByTree (\n -> n.id == pid) notess
        let prevChildIds = sublings <#> \n -> n.id
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
      let noteForest = noteToTree' notes "" topic.noteIds
      let noteTrees = fromFoldable noteForest
      let ids = map (\n -> n.id) noteTrees
      if Foldable.null noteForest 
        then newNote "" 0
        else do 
          H.modify_  _ { 
            topic = topic
            , noteForest = noteForest
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
    delete note = do
      let noteId = note.id
      updateSortInParent note.parentId $ Array.delete noteId
      void $ deleteNote noteId
      changeEditID Nothing

    indent note path = do
      let id = note.id
      nodes <- H.gets _.noteForest
      prevNode <- fromJust' $ Tree.prevPath path >>= Tree.look nodes
      let len = Tree.childrenLenth prevNode
      let source = note.parentId
      let prevNote = Tree.getData prevNode
      let target = prevNote.id
      
      void $ updateNoteById id { parentId: target }

      -- logDebug $ "上一个节点的子元素个数为  " <> show len
      moveSort id source target len
      initNote
    unIndent note path = do
      let id = note.id
      nodes <- H.gets _.noteForest
      parentNode <- fromJust' $ Tree.parentPath path >>= Tree.look' nodes
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
  , noteForest : Tree.emptyForest
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