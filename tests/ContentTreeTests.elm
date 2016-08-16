module ContentTreeTests exposing (all)

import Test exposing (..)
import Expect exposing (..)
import String
import Fuzz exposing (string)
import ContentTree
import Contentful
import Json.Decode as Json
import ContentfulData
import Regex

-- ASSERTIONS


-- TESTS

all : Test
all =
    describe "The ContentTree module"
        [ unbox
        , init
        , tail
        , setActive
        , buildContentTree
        ]

unbox : Test
unbox =
    describe "ContentTree.unbox"
        [ test "turn the model into a List TocItem so we can iterate over it" <|
            \() ->
                Expect.equal [] ( ContentTree.unbox ( fst ContentTree.init ) )
        ]

init : Test
init =
    describe "ContentTree.init"
        [ test "returns an empty model" <|
            \() ->
                Expect.equal [] ( ContentTree.unbox ( fst ContentTree.init ) )
        ]

tail : Test
tail =
    describe "ContentTree.tail"
        [ test "returns the rest of the list, the head element removed" <|
            \() ->
                let input = [1, 2, 3, 4, 5]
                    expected = [2, 3, 4, 5]
                in Expect.equal expected (ContentTree.tail input)

        , test "returns an empty list when the input list is empty instead of (Maybe List a)" <|
            \() -> Expect.equal [] (ContentTree.tail [])
        ]


-- helper function: get navigation item from model
getNavigationItem : (ContentTree.NavigationItem -> Bool) -> ContentTree.Model -> Maybe ContentTree.NavigationItem
getNavigationItem predicate model =
    let getNavigationItem' : List ContentTree.NavigationItem -> Maybe ContentTree.NavigationItem
        getNavigationItem' list =
            case List.head list of
                Just hd ->
                    if predicate hd then
                        Just hd
                    else
                        case getNavigationItem' (ContentTree.unbox hd.children) of
                            Just child -> Just child
                            Nothing -> getNavigationItem' (ContentTree.tail list)
                Nothing -> Nothing

    in getNavigationItem' (ContentTree.unbox model)

-- helper function: to get the active slug from the Model
getActiveSlug : ContentTree.Model -> Maybe String
getActiveSlug model =
    Maybe.map .slug ( getNavigationItem (\item -> item.active) model )

-- helper function to get stub model
getQueryResult : String -> Contentful.QueryResult
getQueryResult json =
    Result.withDefault [] ( Json.decodeString Contentful.queryResultDecoder json )


setActive : Test
setActive =
    describe "ContentTree.setActive"
        [ test "shall set navigation item as active that corresponds to the slug supplied" <|
            \() ->
                let model = (getQueryResult ContentfulData.getNavigationTree ) |> ContentTree.buildContentTree
                in Expect.equal ( Just "documentation" ) ( getActiveSlug (ContentTree.setActive "documentation" model ) ) 

        , test "shall clear all active flags when the slug doesn't exist in the content tree" <|
            \() ->
                let model = (getQueryResult ContentfulData.getNavigationTree ) |> ContentTree.buildContentTree
                in Expect.equal Nothing ( getActiveSlug ( ContentTree.setActive "whatever" model ) )
        ]


buildContentTree : Test
buildContentTree =
    describe "ContentTree.buildContentTree"
        [ test "shall put documents without a parent as top level navigation" <| 
            \() ->
                let model = ( getQueryResult ContentfulData.getNavigationTree ) |> ContentTree.buildContentTree
                    rootCount = List.length ( ContentTree.unbox model )
                    rootTitle =
                        case List.head ( ContentTree.unbox model ) of
                            Just hd -> hd.title
                            Nothing -> ""

                in Expect.true "There should only be one root document" ( rootCount == 1 && rootTitle == "About this Documentation" ) 

        , test "shall put documents with parent as children to the parent document" <|
            \() ->
                let rootID = "6rPDH1vP9YuOQAqqWmaQOi"

                    queryResultTitles = ( getQueryResult ContentfulData.getNavigationTree )
                                        |> List.filter ( \item -> item.fields.parent == ( Just { id = rootID } ) )
                                        |> List.map ( \item -> item.fields.title )

                    rootItemChildrenTitles =
                        case List.head ( ContentTree.unbox ( ContentTree.buildContentTree ( getQueryResult ContentfulData.getNavigationTree ) ) ) of
                            Just hd -> ( ContentTree.unbox hd.children )
                                       |> List.map .title
                            Nothing -> []

                in Expect.equal queryResultTitles rootItemChildrenTitles

                    
        , describe "shall create NavigationItem from ResultItem"
            [ test "by setting id, slug and title" <| 
                \() ->
                    let queryResult = (getQueryResult ContentfulData.getNavigationTree )
                        model = queryResult |> ContentTree.buildContentTree

                        exists : Contentful.ResultItem -> Bool
                        exists item =
                            case getNavigationItem (\nav -> nav.id == item.sys.id && nav.slug == item.fields.slug && nav.title == item.fields.title) model of
                                Just _ -> True
                                Nothing -> False

                    in Expect.true "All result items should be represented in content tree" ( List.all exists queryResult )

            , test "and setting active field to False" <| 
                \() ->
                    let model = (getQueryResult ContentfulData.getNavigationTree ) |> ContentTree.buildContentTree
                    in Expect.true "All result items should be represented in content tree" ( List.all (\nav -> not nav.active) ( ContentTree.unbox model ) )
            ]
        ]


