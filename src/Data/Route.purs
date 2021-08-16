module LinkNote.Data.Route where


import Data.Generic.Rep (class Generic)
import LinkNote.Data.Data (TopicId)
import Prelude (class Eq, class Ord, ($))
import Routing.Duplex (RouteDuplex', root, segment)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))

-- import Routing.

data Route = Home | Setting | TopicList | Topic TopicId

derive instance genericRoute :: Generic Route _
derive instance eqRoute :: Eq Route
derive instance ordRoute :: Ord Route

routeCodec :: RouteDuplex' Route
routeCodec = root $ sum
  { "Home": noArgs
  , "Setting": "setting" / noArgs
  , "TopicList": "topic" / noArgs
  , "Topic": "topic" / segment
  }