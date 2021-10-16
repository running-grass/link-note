module LinkNote.Page.Topic where

import Prelude

import Control.Monad.Error.Class (class MonadThrow, throwError)
import Control.Monad.State (modify_)
import Data.Array (elem, elemIndex, filter, fromFoldable, index, null, sortWith)
import Data.Array as Array
import Data.Array.NonEmpty as NArray
import Data.Foldable (for_)
import Data.Foldable as Foldable
import Data.FunctorWithIndex (mapWithIndex)
import Data.Lens (Lens', Traversal', over, set, traversed, view)
import Data.Lens.Index (ix)
import Data.Lens.Record (prop)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (splitAt)
import Data.String.Regex (Regex, replace, replace', test)
import Data.String.Regex.Flags (global, noFlags)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.Traversable (class Traversable)
import Data.Tuple (Tuple(..))
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
import LinkNote.Capability.Resource.Note (class ManageNote, generateEmptyNote, getAllNotesByHostId, updateNoteById)
import LinkNote.Capability.Resource.Topic (class ManageTopic, getTopics, updateTopicById)
import LinkNote.Capability.UUID (class UUID)
import LinkNote.Component.HTML.Utils (css)
import LinkNote.Component.Store as LS
import LinkNote.Data.Array (modifyAtLast, modifyAtLastArray)
import LinkNote.Data.Data (Note, NoteId, Topic, TopicId, Point)
import LinkNote.Data.Tree (ForestIndexPath)
import LinkNote.Data.Tree as Tree
import Type.Proxy (Proxy(..))
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
  = ChangeNoteText ForestIndexPath Note String 
  | IgnorePaste CE.ClipboardEvent
  | HandleKeyUp (Tree.Tree (Tuple Note ForestIndexPath)) KE.KeyboardEvent
  | HandleKeyDown KE.KeyboardEvent
  | InitComp
  | Receive ConnectedInput
  | SubmitIpfs String
  | InsertTopicLink Topic
  | ClickNote ME.MouseEvent NoteId

foreign import addPasteListenner :: (forall a. a -> Maybe a -> a) -> Maybe IPFS -> (Function String (Effect Unit)) -> Effect Unit

noteToTree :: Array Note -> Array NoteId -> Tree.Forest Note
noteToTree notelist sortIds = Tree.Forest $ map toTree $ sortChild filterdList
  where
    filterdList :: Array Note
    filterdList = filter (\note -> Array.elem note.id sortIds) notelist
    toTree note = Tree.Node note $ noteToTree notelist note.childrenIds
    sortChild :: Array Note -> Array Note
    sortChild = sortWith \node -> fromMaybe (Array.length sortIds) (elemIndex node.id sortIds)    

_childIds :: Lens' (Tree.Tree Note) String
_childIds = Tree._data <<< prop (Proxy :: Proxy "id")

_getChildIds :: Array (Tree.Tree Note) -> Array String
_getChildIds = over traversed (view _childIds)

updateChildId :: Tree.Forest Note -> Tree.Forest Note
updateChildId = Tree.map' \(Tree.Node x (Tree.Forest xs)) -> x { childrenIds = _getChildIds xs }

updateTopicChildId :: Tree.Forest Note -> Topic -> Topic
updateTopicChildId (Tree.Forest fs) topic = topic { noteIds = _getChildIds fs }

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

renderNote :: forall  a. String -> Maybe String -> Tree.Tree (Tuple Note ForestIndexPath) -> HH.HTML a Action
renderNote ipfsGatway currentId noteTree@(Tree.Node (Tuple note path) (Tree.Forest children))  = 
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
              , HE.onValueInput \val -> ChangeNoteText path note val
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
        else HH.ul [css $ "list-disc pl-6"] $ children <#> renderNote ipfsGatway currentId 
    ]

render :: forall cs m. State -> H.ComponentHTML Action cs m
render state =
  HH.div_
    [
    HH.ul [css "list-disc pl-6"] $ renderList noteForest_
    , case state.popoverPosition of
        Just p -> HH.div [ 
          css "fixed bg-blue-300 h-80 w-80", 
          style $ ("left: " <> show p.x <> "px; top: " <> show p.y <> "px;") ] [ 
            HH.ul_ $ mapWithIndex (\idx topic -> HH.li [ HE.onClick \_ -> InsertTopicLink topic, css $ if state.popoverCurrent == idx then "bg-red-500" else "" ] [HH.text topic.name]) state.popoverList 
          ]
        Nothing -> HH.span_ []
    ]
  where 
    renderList (Tree.Forest tas) = tas <#> renderNote state.ipfsGatway state.currentId
    noteForest_ = mapWithIndex (\path note -> Tuple note path) state.noteForest

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
    let appendText = "[[" <> topic.name <> "|" <> topic.id <> "]]"
    insertLinkToNote appendText
  ChangeNoteText path note newHeading ->  do
    nowTime <- now
    noteForest <- H.gets _.noteForest 
    let note' = note { heading = newHeading, updated = nowTime }
    updateNoteForest $ Just $ set (ix path) note' noteForest
  SubmitIpfs path -> do
    let fileId = "file-" <> path
    void $ addFile { cid: path,  id: fileId, mime: "", type: "" }
    let appendText = "((" <> fileId <> "))"
    void $ H.liftEffect $ insertText appendText
  InitComp -> do
    logDebug "初始化组件"
    
    topic <- H.gets _.topic
    notes <- getAllNotesByHostId topic.id

    let noteForest = noteToTree notes topic.noteIds
    let noteTrees = fromFoldable noteForest
    let ids = map (\n -> n.id) noteTrees
    if Foldable.null noteForest 
      then newNote $ NArray.singleton (0 - 1)
      else do 
        H.modify_  _ { 
          noteForest = noteForest
          , visionNoteIds = ids
        }
        handdleAutoFoucs

    maybeIpfs <- H.gets _.ipfs
    _ <- H.subscribe =<< subscriptPaste maybeIpfs
    ipfsGatway <- getIpfsGatewayPrefix
    H.modify_ _ { ipfsGatway = ipfsGatway}

  ClickNote mev nid -> do
    H.liftEffect $ stopPropagation $ ME.toEvent mev
    changeEditID $ Just nid
  HandleKeyDown kbe 
    | elem (KE.key kbe) ["Tab", "Enter", "ArrowUp", "ArrowDown"] -> do 
      ignoreEvent kbe
    | KE.metaKey kbe -> do 
      case KE.key kbe of
        "s" -> do
          ignoreEvent kbe
          syncToDB
        _ -> pure unit
    | otherwise -> do 
      pure unit
  
  HandleKeyUp (Tree.Node (Tuple note path) _) kbe 
    -- 按下Shift修饰键的情况
    | KE.shiftKey kbe -> do
      logAnyM "shelf s"
      nodes <- H.gets _.noteForest 
      case KE.key kbe of
        -- 反缩进
        "Tab" -> do
          updateNoteForest $ targetPath >>= \p -> Tree.moveSubTree path p nodes 
          where 
            targetPath :: Maybe ForestIndexPath
            targetPath = case NArray.length path of
              1 -> Nothing
              _ -> NArray.fromArray =<< (modifyAtLastArray (_ + 1) $ NArray.init path)
        -- 把当前标题向上移动
        "ArrowUp" -> do 
          let prevPath = modifyAtLast (_ - 1) path
          updateNoteForest $ Tree.moveSubTree path prevPath nodes
        -- 把当前标题向下移动
        "ArrowDown" -> do
          let nextPath = modifyAtLast (_ + 2) path
          updateNoteForest $ Tree.moveSubTree path nextPath nodes
        _ -> pure unit
    | KE.altKey kbe -> do
      logAnyM "alt"
      pure unit
    | KE.metaKey kbe -> do
      logAnyM "command"
      pure unit
    | KE.ctrlKey kbe -> do 
      logAnyM "cotrol s"
      pure unit
    | (not KE.shiftKey kbe) && (not KE.ctrlKey kbe) && (not KE.altKey kbe) && (not KE.metaKey kbe)-> do 
      -- 没有任何按键修饰符
      popoverPosition <- H.gets _.popoverPosition
      case KE.key kbe, popoverPosition of
        "Enter", Just _ -> do 
          idx <- H.gets _.popoverCurrent
          list <- H.gets _.popoverList
          let topic' = index list idx
          case topic' of 
            Nothing -> insertLinkToNote $ "[[" <> "" <> "]]"
            Just topic -> handleAction $ InsertTopicLink topic
        "Enter", _ -> newNote path
        "Tab", _ -> do 
          nodes <- H.gets _.noteForest
          case isHead of 
            true -> pure unit
            false -> do
              prevNode <- fromJust' $ Tree.prevPath path >>= Tree.look nodes
              let len = Tree.childrenLenth prevNode
              let targetPath = NArray.snoc (modifyAtLast (_ - 1) path) len
              updateNoteForest $ Tree.moveSubTree path targetPath nodes
          where
            isHead = NArray.last path == 0
        
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
          if popoverCurrent == (Array.length list) - 1
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
              | "" == text -> delete path 
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
    | otherwise -> do 
      logAnyM "unknow"
      pure unit 
  IgnorePaste ev -> H.liftEffect $ preventDefault $ CE.toEvent ev
  Receive input -> do
    H.put $ initialState input
    handleAction InitComp
  where
    ignoreEvent kbe = do
      H.liftEffect $ stopPropagation $ KE.toEvent kbe
      H.liftEffect $ preventDefault $ KE.toEvent kbe

    newNote path = do
      topic <- H.gets _.topic 
      nodes <- H.gets _.noteForest
      note <- generateEmptyNote "topic" topic.id ""
      let newPath = modifyAtLast (_ + 1) path
      
      updateNoteForest $ Tree.insertLeaf newPath note nodes
      changeEditID $ Just note.id
    handdleAutoFoucs = do
      maybeId <- H.gets _.currentId 
      H.liftEffect $ autoFocus $ fromMaybe "dummy" maybeId
    changeEditID mb = do 
      H.modify_ _ { currentId = mb
                  , popoverPosition = Nothing
                  , popoverList = [] }
      handdleAutoFoucs
    delete path = do
      nodes <- H.gets _.noteForest
      updateNoteForest $ Tree.deleteAt path nodes
      changeEditID Nothing
    syncToDB = do
      logAnyM "save to db"
      nodes <- H.gets _.noteForest
      topic <- H.gets _.topic 
      let nodes' = updateChildId nodes
      let topic' = updateTopicChildId nodes topic

      logAnyM nodes'
      void $ updateTopicById topic'.id topic'
      for_ nodes' $ \note -> updateNoteById note.id note
      H.modify_ _ {
        noteForest = nodes'
        , topic = topic'
      }
      
    updateNoteForest Nothing = pure unit  
    updateNoteForest (Just noteForest) = do
      let noteTrees = fromFoldable noteForest
      let ids = map (\n -> n.id) noteTrees
      H.modify_ _ { 
        noteForest = noteForest
        , visionNoteIds = ids
      }
      handdleAutoFoucs
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
          handdleAutoFoucs
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