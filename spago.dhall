{-
Welcome to a Spago project!
You can edit this file as you like.

Need help? See the following resources:
- Spago documentation: https://github.com/purescript/spago
- Dhall language tour: https://docs.dhall-lang.org/tutorials/Language-Tour.html

When creating a new Spago project, you can use
`spago init --no-comments` or `spago init -C`
to generate this file without the comments in this block.
-}
{ name = "my-project"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "argonaut"
  , "argonaut-codecs"
  , "argonaut-generic"
  , "arrays"
  , "console"
  , "datetime"
  , "effect"
  , "either"
  , "exceptions"
  , "foldable-traversable"
  , "formatters"
  , "halogen"
  , "halogen-hooks"
  , "halogen-store"
  , "halogen-subscriptions"
  , "html-parser-halogen"
  , "integers"
  , "math"
  , "maybe"
  , "now"
  , "option"
  , "prelude"
  , "profunctor-lenses"
  , "psci-support"
  , "record"
  , "routing"
  , "routing-duplex"
  , "safe-coerce"
  , "spec"
  , "strings"
  , "tailrec"
  , "transformers"
  , "tuples"
  , "uuid"
  , "web-clipboard"
  , "web-dom"
  , "web-events"
  , "web-html"
  , "web-storage"
  , "web-uievents"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
