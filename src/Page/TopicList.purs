module LinkNote.Page.TopicList where

import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import LinkNote.Component.HTML.Header (header)
import LinkNote.Data.Setting (IPFSInstanceType)
import Prelude (Unit, pure, unit)

type Input = { 
  ipfsInstanceType :: IPFSInstanceType
}

type State = { 
    ipfsInstanceType :: IPFSInstanceType
}

data Action = Submit  

render :: forall cs m. State -> H.ComponentHTML Action cs m
render _ =
  HH.div_ [
    HH.text "I am a topic list"
  ]

handleAction :: forall cs o m . MonadAff m =>  Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  Submit ->  do
    pure unit 

initialState :: Input-> State
initialState input = { 
    ipfsInstanceType: input.ipfsInstanceType
  }

component :: forall q  o m. MonadAff m => H.Component q Input o m
component =
  H.mkComponent
    { 
      initialState
    , render
    , eval: H.mkEval H.defaultEval { 
        handleAction = handleAction
      }
    }
