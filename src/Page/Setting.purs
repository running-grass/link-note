module LinkNote.Page.Setting where

import Prelude

import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import LinkNote.Capability.LogMessages (class LogMessages)
import LinkNote.Capability.ManageDB (class ManageDB, deleteLocalDB, exportLocalDB)
import LinkNote.Capability.ManageStore (class ManageStore, setIpfsInstanceType)
import LinkNote.Component.HTML.Utils (buttonClass, css)
import LinkNote.Data.Setting (IPFSInstanceType, parseIpfsInsType, toString)

type Input = { 
  ipfsInstanceType :: IPFSInstanceType
}

type State = { 
    ipfsInstanceType :: IPFSInstanceType
    , selected :: String
}

data Action = DeleteDB 
  | ExportDB
  | ChangeIpfsInsType String

render :: forall cs m. State -> H.ComponentHTML Action cs m
render st  =
  HH.section_ [
    HH.div [css "mb-4"] [
      -- HH.span_ [HH.text st.selected] ,
      HH.select [ HE.onValueChange ChangeIpfsInsType, HP.value st.selected] [
        HH.option [ HP.value "unused"] [HH.text "不使用IPFS"]
        , HH.option [ HP.value "local" ] [HH.text "本地Go节点"]
        , HH.option [ HP.value "brave" ] [HH.text "brave浏览器"]
      ]
    ]
    , HH.div [ css "mb-4" ] [
      HH.button [ buttonClass "", HE.onClick \_ -> ExportDB] [ HH.text "导出"]
    ]
    , HH.div_ [
      HH.button [ buttonClass "",  HE.onClick \_ -> DeleteDB ] [ HH.text "删库"]
    ]
  ]

initialState :: Input-> State
initialState input = { 
  ipfsInstanceType: input.ipfsInstanceType
  , selected : toString input.ipfsInstanceType
}

component :: forall q  o m. 
  MonadAff m 
  => ManageDB m
  => ManageStore m
  => LogMessages m
  => H.Component q Input o m
component =
  H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval { 
        handleAction = handleAction
      }
    }
  where
    handleAction = case _ of
      DeleteDB ->  do
        deleteLocalDB
      ExportDB -> do
        exportLocalDB 
      ChangeIpfsInsType insType -> do
        H.modify_ _ { selected = insType}
        setIpfsInstanceType $ parseIpfsInsType insType
