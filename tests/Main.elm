port module Main exposing (..)

import TableOfContentsTests as TableOfContents
import SearchTests as Search
import ContentfulTests as Contentful
import ContentTreeTests as ContentTree
import Test exposing (describe)
import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)

tests =
    describe "bitdoc"
        [ TableOfContents.all
        , Search.all
        , Contentful.all
        , ContentTree.all
        ]

main : Program Never
main =
    run emit tests


port emit : ( String, Value ) -> Cmd msg
