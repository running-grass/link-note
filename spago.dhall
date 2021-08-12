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
  , "arrays"
  , "effect"
  , "either"
  , "exceptions"
  , "halogen"
  , "halogen-store"
  , "halogen-subscriptions"
  , "html-parser-halogen"
  , "maybe"
  , "option"
  , "prelude"
  , "psci-support"
  , "routing"
  , "routing-duplex"
  , "safe-coerce"
  , "strings"
  , "tailrec"
  , "transformers"
  , "uuid"
  , "web-clipboard"
  , "web-dom"
  , "web-events"
  , "web-file"
  , "web-html"
  , "web-uievents"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
