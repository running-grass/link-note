module LinkNote.Page.Setting where

import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import LinkNote.Capability.ManageDB (class ManageDB, deleteLocalDB, exportLocalDB)
import LinkNote.Component.HTML.Utils (buttonClass, css)
import LinkNote.Data.Setting (IPFSInstanceType)

type Input = { 
  ipfsInstanceType :: IPFSInstanceType
}

type State = { 
    ipfsInstanceType :: IPFSInstanceType
}

data Action = DeleteDB | ExportDB

render :: forall cs m. State -> H.ComponentHTML Action cs m
render _ =
  HH.section_ [
    HH.div [ css "mb-4" ] [
      HH.button [ buttonClass "", HE.onClick \_ -> ExportDB] [ HH.text "导出"]
    ]
    , HH.div_ [
      HH.button [ buttonClass "",  HE.onClick \_ -> DeleteDB ] [ HH.text "删库"]
    ]
  ]

initialState :: Input-> State
initialState input = { 
  ipfsInstanceType: input.ipfsInstanceType
}

component :: forall q  o m. 
  MonadAff m 
  => ManageDB m
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