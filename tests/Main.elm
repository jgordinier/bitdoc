port module Main exposing (..)

import TableOfContentsTests as TableOfContents
import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)


main : Program Never
main =
    run emit TableOfContents.all


port emit : ( String, Value ) -> Cmd msg
