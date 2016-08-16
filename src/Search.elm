{- Search

   Summary: This module is responsible for free text search of documents. It will query the Contentful
   API using the Contentful module, and present the result in a list.
-}
module Search exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing ((:=))
import String
import Regex exposing (HowMany(All))
import Contentful exposing (Msg(..))



-----------------------------------------------------------------------------------------
-- MODEL
-----------------------------------------------------------------------------------------

type alias Model =
    { query : String
    , count : Int
    , result : List SearchResultItem
    }

type alias SearchResultItem =
    { title : String
    , slug : String
    , version : String
    , abstract : String 
    }


{-| init:

    Will create a new model with no command.
-}
init : (Model, Cmd Msg)
init = (Model "" 0 [], Cmd.none)



-----------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------

{-| Msg:

    @Query query: Will set the query from the input field to the supplied query.

    @Clear: Will clear the query and the search result.

    @Search: Will perform the search of the query.

    @SubMsg Contentful.Msg: Will retrieve the search result and present it to the user.
-}
type Msg
    = Query String
    | Clear
    | Search
    | SubMsg Contentful.Msg

{-| update:

    Will update the model. While typing in the input field, the query will be updated through the
    Query message. If the user hits [esc] the query and search result will be cleared, and if the
    user presses [enter] the query will be executed. Once the query execution is returned it will
    be handled by the SubMsg.

    @msg: The message that tells what is to be updated.

    @model: The model that should be updated.
-}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Query query ->
            ( { model | query = query }, Cmd.none )
        Clear ->
            init 
        Search ->
            ( model, Cmd.map SubMsg (Contentful.search model.query) )
        SubMsg subMsg ->
            case subMsg of
                DocumentQuerySucceed result ->
                    ( { model | count = List.length result, result = (mapResult result) }, Cmd.none)
                DocumentQueryFail _ ->
                    ( model, Cmd.none )


{-| mapResult:

    Take the search result from Contentful and turn it into SearchResultItem that we use to present
    it to the user.

    @result: The search result from the API.
-}
mapResult : Contentful.QueryResult ->  List SearchResultItem
mapResult result =
    List.map (\item -> SearchResultItem item.fields.title item.fields.slug item.fields.version (mapAbstract item.fields.content)) result

{-| mapAbstract:

    Create an abstract from the markdown content string. Do this by removing all special markdown
    characters, only display text portion of links and limit it to 500 characters.

    @content: The content field of the search result.
-}
mapAbstract : String -> String
mapAbstract content =
    let firstSubMatch : List (Maybe String) -> String
        firstSubMatch list = Maybe.withDefault "" (Maybe.withDefault (Just "") (List.head list))

       -- remove links
    in Regex.replace All (Regex.regex "[(.*?)]\\(.*?\\)") (\match -> firstSubMatch match.submatches) content
       -- remove headlines
       |> String.lines
       |> List.map (Regex.replace All (Regex.regex "^#+") (\_ -> ""))
       |> String.join "\n"
       -- remove `
       |> Regex.replace All (Regex.regex "[`]") (\_ -> "")
       -- pick 597 characters
       |> String.left 497
       -- pad to 500 with .
       |> String.padRight 3 '.'



-----------------------------------------------------------------------------------------
-- VIEW 
-----------------------------------------------------------------------------------------

{-| KeyEvent:

    The static type of the parsed JSON event callback result from a keypress.
-}
type alias KeyEvent = 
    { keyCode : Int
    , target : TargetEvent
    }

type alias TargetEvent =
    { value : String 
    }

{-| eventDecoder:

    Parsing the JSON result from the triggered keyevent into a KeyEvent instance.
-}
eventDecoder : Json.Decoder KeyEvent
eventDecoder = Json.object2 KeyEvent ( "keyCode" := Json.int ) ( "target" := targetDecoder )

targetDecoder : Json.Decoder TargetEvent
targetDecoder = Json.object1 TargetEvent ( "value" := Json.string )

{-| keyEvent:

    Helper function to create a KeyEvent

    @keyCode: The number representing the key that was pressed.
    @target: The actual text of the input field of the key that was pressed.
-}    
keyEvent : Int -> String -> KeyEvent
keyEvent keyCode target = { keyCode = keyCode, target = { value = target } }

{-| keyPress:

    Event handler for "keyup" on the search input field. If [enter] was pressed, perform a search.
    If [esc] was pressed, clear the field and the search result. Otherwise, do nothing.
-}
keyPress : KeyEvent -> Msg
keyPress event =
    case event.keyCode of 
        -- enter
        13 -> Search
        -- escape
        27 -> Clear
        -- other, this is really handled by `onInput Query`
        _ -> Query event.target.value

{-| onKeyUp:

    An event that triggers when a key is released.

    @tagger: the event handler for this event.
-}
onKeyUp : (KeyEvent -> msg) -> Attribute msg
onKeyUp tagger = on "keyup" (Json.map tagger eventDecoder)

{-| viewSearchInput:

    Render the search input field.

    @model: The model that should be rendered.
-}
viewSearchInput : Model -> Html Msg
viewSearchInput model =
    input [ class "search", placeholder "Type to Search", value model.query, onInput Query, onKeyUp keyPress ] []

{-| viewSearchResult:

    Render the search result.

    @model: The model that should be rendered.
-}
viewSearchResult : Model -> Html Msg
viewSearchResult model =
    let viewSearchResultItem : SearchResultItem -> Html Msg
        viewSearchResultItem item =
            li []
            [ h2 []
              [ a [href ("#/" ++ item.slug)] [text item.title]
              ]
            , p [] [text item.abstract]
            ]

    in  div [class "search-result"]
        [ h1 [class "search-result-title"]
          [ span [class "search-result-number"] [text (toString model.count)]
          , text " results matching "
          , span [class "search-result-query"] [text model.query]
          ]
        , ul [class "search-result-items"] (List.map viewSearchResultItem model.result)
        ]
