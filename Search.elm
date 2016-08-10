module Search exposing (Model, init, update, Msg, viewSearchInput, viewSearchResult)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task exposing (Task)
import Json.Decode as Json exposing ((:=))
import Markdown
import String
import Regex exposing (HowMany(All))
import Contentful exposing (..)

main =
    App.program    
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

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

init : (Model, Cmd Msg)
init = (Model "" 0 [], Cmd.none)

-- UPDATE

type Msg
    = Query String
    | Clear
    | Search
    | SubMsg Contentful.Msg

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
            ( updateHelper model subMsg )

updateHelper : Model -> Contentful.Msg -> (Model, Cmd Msg)
updateHelper model msg =
    case msg of
        DocumentQuerySucceed result ->
            ( { model | count = List.length result, result = (mapResult result) }, Cmd.none)
        DocumentQueryFail _ ->
            ( model, Cmd.none )


mapResult : Contentful.QueryResult ->  List SearchResultItem
mapResult result =
    List.map (\item -> SearchResultItem item.fields.title item.fields.slug item.fields.version (mapAbstract item.fields.content)) result

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

-- VIEW 

type alias KeyEvent = 
    { keyCode : Int
    , target : TargetEvent
    }

type alias TargetEvent =
    { value : String 
    }

keyEvent : Int -> String -> KeyEvent
keyEvent keyCode target = { keyCode = keyCode, target = { value = target } }

keyPress : KeyEvent -> Msg
keyPress event =
    case event.keyCode of 
        -- enter
        13 -> Search
        -- escape
        27 -> Clear
        -- other
        _ -> Query event.target.value

onKeyUp : (KeyEvent -> msg) -> Attribute msg
onKeyUp tagger = on "keyup" (Json.map tagger eventDecoder)

eventDecoder : Json.Decoder KeyEvent
eventDecoder = Json.object2 KeyEvent ( "keyCode" := Json.int ) ( "target" := targetDecoder )

targetDecoder : Json.Decoder TargetEvent
targetDecoder = Json.object1 TargetEvent ( "value" := Json.string )

view : Model -> Html Msg
view model =
    div []
        [ viewSearchInput model
        , if model.count > 0 then viewSearchResult model else div [] []
        ]

viewSearchInput : Model -> Html Msg
viewSearchInput model =
    input [ class "search", placeholder "Type to Search", value model.query, onKeyUp keyPress ] []


viewSearchResult : Model -> Html Msg
viewSearchResult model =
    div [class "search-result"]
    [ h1 [class "search-result-title"]
      [ span [class "search-result-number"] [text (toString model.count)]
      , text " results matching "
      , span [class "search-result-query"] [text model.query]
      ]
    , ul [class "search-result-items"] (List.map viewSearchResultItem model.result)
    ]

viewSearchResultItem : SearchResultItem -> Html Msg
viewSearchResultItem item =
    li []
    [ h2 []
      [ a [href ("#/" ++ item.slug)] [text item.title]
      ]
    , p [] [text item.abstract]
    ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

