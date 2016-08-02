import Html exposing (..) 
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation
import String
import Http
import Markdown
import Json.Decode as Json
import Json.Decode exposing ((:=))
import Task

main =
    Navigation.program urlParser
        { init = init 
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }

-- URL PARSERS

toUrl : String -> String
toUrl id = "#/" ++ id

fromUrl : String -> (Result String String)
fromUrl url = Result.fromMaybe ("Error parsing url: " ++ url) (List.head (List.reverse (String.split "/" url)))

urlParser : Navigation.Parser (Result String String)
urlParser = Navigation.makeParser (fromUrl << .hash)

-- MODEL

type alias Model =
    { slug : String
    , title : String
    , content : String }

init : Result String String -> (Model, Cmd Msg)
init slug =
    ( Model "documentation" "Loading" "Please wait...", getDocumentBySlug "documentation" )

type alias DocumentFields =
    { title : String
    , slug : String
    , version: String
    , content: String
    }

defaultDocument = DocumentFields "Here be dragons" "" "Failed to parse json from Contentful"

-- UPDATE

type Msg
    = GetDocument
    | FetchSucceed (List DocumentFields)
    | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetDocument ->
            (model, getDocumentBySlug model.slug)
        FetchSucceed docs ->
            case List.head docs of
                Just fields -> (Model model.slug fields.title fields.content, Cmd.none)
                Nothing -> (Model model.slug "Not found" "The specified document was not found", Cmd.none)
        FetchFail _ ->
            (model, Cmd.none)

urlUpdate : (Result String String) -> Model -> (Model, Cmd Msg)
urlUpdate urlResult model =
    case urlResult of
        Ok slug -> update GetDocument { model | slug = slug }
        Err message -> (Model "error" "Failed to find document" message, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ a [href "#/documentation"] [
            h1 [] [text "bit-lang documentation v0.0"]
          ]
        , menu
        , h2 [class "document-title"] [text model.title]
        , div [] [ Markdown.toHtml [] model.content ]
        ]

menu =
    ul [class "top-navigation"]
        [ li [] [a [href "#/language"] [text "Language"]]
        , li [] [a [href "#/modules"] [text "Modules"]]
        , li [] [a [href "#/examples"] [text "Examples"]]
  ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- HTTP
access_token = "eb3f72d5bce55840bd6905e941091ff435d9005d1c29e1906c70ad384e4a2693"
space = "3on7pmzbo8hd"
contentful = "https://cdn.contentful.com/spaces/" ++ space ++ "/"

getDocumentBySlug : String -> Cmd Msg
getDocumentBySlug slug =
    Task.perform FetchFail FetchSucceed (Http.get queryDocumentDecoder (Http.url (contentful ++ "entries/") [("access_token", access_token), ("content_type", "document"), ("fields.slug", slug), ("include", "0"), ("limit", "1")]))

documentDecoder : Json.Decoder DocumentFields
documentDecoder =
    let decoder = Json.object4 DocumentFields
                    ( "title" := Json.string )
                    ( "slug" := Json.string )
                    ( "version" := Json.string )
                    ( "content" := Json.string )
    in Json.at ["fields"] decoder

queryDocumentDecoder : Json.Decoder (List DocumentFields)
queryDocumentDecoder =
    Json.at ["items"] (Json.list documentDecoder)
