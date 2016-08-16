module ContentfulTests exposing (all)

import Test exposing (..)
import Expect exposing (..)
import String
import Json.Decode as Json
import Fuzz exposing (string)
import Contentful
import ContentfulData

-- ASSERTIONS

contains : String -> String -> Expectation
contains substr input =
    case String.contains substr input of
        True -> Expect.pass
        False -> Expect.fail ( "Expected string '" ++ input ++ "' to contain '" ++ substr ++ "'" )

resultOk : Result String a' -> Expectation
resultOk value =
    case value of
        Ok _ -> Expect.pass
        Err msg -> Expect.fail msg

-- TESTS

all : Test
all =
    describe "The Contentful module"
        [ getDocumentsQuery
        , getDocumentQuery
        , queryResultDecoder
        ]

access_token = "eb3f72d5bce55840bd6905e941091ff435d9005d1c29e1906c70ad384e4a2693"
space = "3on7pmzbo8hd"

getDocumentsQuery : Test
getDocumentsQuery =
    describe "Contentful.getDocumentsQuery"
        [ test "is URL containing the space id" <|
            \() -> 
                let expected = "/" ++ space ++ "/"
                in contains expected ( Contentful.getDocumentsQuery [] )

        , test "is URL that appends access_token" <|
            \() ->
                let expected = "access_token=" ++ access_token
                in contains expected ( Contentful.getDocumentsQuery [] )

        , test "is URL that specify the content_type to be 'document'" <|
            \() ->
                let expected = "content_type=document"
                in contains expected ( Contentful.getDocumentsQuery [] )

        , test "creates an URL with custom parameters as URL query params" <|
            \() ->
                let params = [("one", "1"), ("two", "2")]
                    expected = "&one=1&two=2"
                in contains expected ( Contentful.getDocumentsQuery params )
        ]

getDocumentQuery : Test
getDocumentQuery =
    describe "Contentful.getDocumentQuery"
        [ test "is an URL containing the space id" <|
            \() ->
                let expected = "/" ++ space ++ "/"
                in contains expected ( Contentful.getDocumentQuery "abc123" )

        , test "is an URL that appends the access token" <|
            \() ->
                let expected = "access_token=" ++ access_token
                in contains expected ( Contentful.getDocumentQuery "abc123" )

        , test "appends the ID as last part of the location before the URL params" <|
            \() ->
                let id = "abc123"
                    expected = "entries/" ++ id ++ "?"
                in contains expected ( Contentful.getDocumentQuery id )
        ]


queryResultDecoder : Test
queryResultDecoder =
    describe "Contentful.queryResultDecoder"
        [ test "should decode response from getDocumentBySlug" <|
            \() -> resultOk ( Json.decodeString Contentful.queryResultDecoder ContentfulData.getDocumentBySlug )

        , test "should decode response from getNavigationTree" <|
            \() -> resultOk ( Json.decodeString Contentful.queryResultDecoder ContentfulData.getNavigationTree )

        , test "should decode response from search" <| 
            \() -> resultOk ( Json.decodeString Contentful.queryResultDecoder ContentfulData.search )
        ]

