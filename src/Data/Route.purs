module LinkNote.Data.Route where

import Data.Generic.Rep (class Generic)
import LinkNote.Data.Data (TopicId)
import Prelude (class Eq, class Ord, ($))
import Routing.Duplex (RouteDuplex', root, segment)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))


data Route = Home | Setting | TopicList | Topic TopicId

derive instance Generic Route _
derive instance Eq Route
derive instance Ord Route

routeCodec :: RouteDuplex' Route
routeCodec = root $ sum
  { "Home": noArgs
  , "Setting": "setting" / noArgs
  , "TopicList": "topic" / noArgs
  , "Topic": "topic" / segment
  }