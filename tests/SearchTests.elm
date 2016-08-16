module SearchTests exposing (all)

import Test exposing (..)
import Expect exposing (..)
import String
import Fuzz exposing (string)
import Search exposing (Msg(..))
import Contentful

-- ASSERTIONS




-- TESTS

all : Test
all =
    describe "The Search module"
        [ init
        , update
        ]


init : Test
init =
    describe "Search.init"
        [ test "creates a new model with empty query" <|
            \() -> Expect.equal "" (fst Search.init).query

        , test "creates a new model with 0 search results" <|
            \() -> Expect.equal 0 (fst Search.init).count

        , test "creates a new model with empty search result set" <|
            \() -> Expect.equal [] (fst Search.init).result
        ]

update : Test
update =
    describe "Search.update"
        [ describe "Msg.Query"
            [ test "updates the model with new query" <|
                \() -> let query = "my seach query"
                           model = (fst Search.init)
                           msg = Query query
                       in  Expect.equal query ( fst ( Search.update msg model ) ).query
            ]
        , describe "Msg.Clear"
            [ test "clears the model to a new model deleting the query and result" <|
                \() -> let model = Search.Model "my query" 5 []
                       in Expect.equal Search.init ( Search.update Clear model )
            ]
        ]

queryResult = 
        [ Contentful.ResultItem
              ( Contentful.SysResult "abc123" )
              ( Contentful.FieldsResult "My title 1" "mytitle1" "0.1" "This is my content" Nothing )
        , Contentful.ResultItem
              ( Contentful.SysResult "abc124" )
              ( Contentful.FieldsResult "My title 2" "mytitle2" "0.1" "This is my second content" Nothing )
        ]

mapResult : Test
mapResult =
    describe "Search.mapResult"
        [ describe "turns a Contentful.QueryResult into a List SearchResultItem"
            [ test "by mapping fields.title to title" <|
                \() -> let expected = ["My title 1", "My title 2"]
                       in Expect.equal expected ( List.map .title ( Search.mapResult queryResult ) )
            ]
        ]
