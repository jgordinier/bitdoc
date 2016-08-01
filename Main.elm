import Html exposing (..) 
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Markdown
import Json.Decode as Json
import Json.Decode exposing ((:=))
import Task

main =
    App.program
        { init = init "6rPDH1vP9YuOQAqqWmaQOi"
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- MODEL

type alias Model =
    { id : String
    , title : String
    , content : String }

init : String -> (Model, Cmd Msg)
init id =
    ( Model id "Loading" "Please wait...", getDocument id )

type alias DocumentFields =
    { title : String
    , version: String
    , content: String
    }

defaultDocument = DocumentFields "Here be dragons" "" "Failed to parse json from Contentful"

-- UPDATE

type Msg
    = GetDocument
    | FetchSucceed DocumentFields
    | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetDocument ->
            (model, getDocument model.id)
        FetchSucceed fields ->
            (Model model.id fields.title fields.content, Cmd.none)
        FetchFail _ ->
            (model, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ a [href "6rPDH1vP9YuOQAqqWmaQOi"] [
            h1 [] [text "bit-lang documentation v0.0"]
          ]
        , menu
        , h2 [class "document-title"] [text model.title]
        , div [] [ Markdown.toHtml [] model.content ]
        ]

menu =
    ul [class "top-navigation"]
        [ li [] [a [href "6dykQ6RfdCc8e2cQYsACky"] [text "Language"]]
        , li [] [a [href "25y6y2ecp2yse0i8Ww2GUC"] [text "Modules"]]
        , li [] [a [href "3UjGDZMzRK0guqOSE8gcYY"] [text "Examples"]]
  ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- HTTP
contentfulGetById : String -> Http.Request
contentfulGetById id =
    { verb = "GET"
    , headers =
        [ ("Authorization", "Bearer eb3f72d5bce55840bd6905e941091ff435d9005d1c29e1906c70ad384e4a2693")
        ]
    , url = "https://cdn.contentful.com/spaces/3on7pmzbo8hd/entries/" ++ id
    , body = Http.empty
    }

getDocument : String -> Cmd Msg
getDocument id =
    Task.perform FetchFail FetchSucceed (Http.fromJson documentDecoder (Http.send Http.defaultSettings (contentfulGetById id)))


documentDecoder : Json.Decoder DocumentFields
documentDecoder =
    let decoder = Json.object3 DocumentFields
                    ( "title" := Json.string )
                    ( "version" := Json.string )
                    ( "content" := Json.string )
    in Json.at ["fields"] decoder
