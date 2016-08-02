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
import Task exposing (..)

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
toUrl slug = "#/" ++ slug

fromUrl : String -> (Result String String)
fromUrl url = Result.fromMaybe ("Error parsing url: " ++ url) (List.head (List.reverse (String.split "/" url)))

urlParser : Navigation.Parser (Result String String)
urlParser = Navigation.makeParser (fromUrl << .hash)

-- MODEL

type alias Model =
    { id : String
    , version : String
    , slug : String
    , title : String
    , content : String
    , mainNav : Navigation }

type alias Navigation = List NavigationItem

type alias NavigationItem =
    { version: String
    , slug : String
    , title : String
    }       

init : Result String String -> (Model, Cmd Msg)
init slug =
    ( Model "" "" "" "Loading" "Please wait..." [], getDocumentRoot )

-- UPDATE

type Msg
    = GetDocument
    | FetchSucceed QueryResult
    | FetchNavigation QueryResult
    | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetDocument ->
            (model, getDocumentBySlug model.slug)

        FetchSucceed queryResult ->
            case List.head queryResult of
                Just item -> let newModel = toModel item
                             in ( { newModel | mainNav = model.mainNav }, getNavigation newModel.id )
                Nothing -> (Model model.id model.version model.slug "Not found" "The specified document was not found" model.mainNav, Cmd.none)

        FetchNavigation queryResult ->
            ( { model | mainNav = List.map toNavigationItem queryResult }, Cmd.none )

        FetchFail _ ->
            (model, Cmd.none)

urlUpdate : (Result String String) -> Model -> (Model, Cmd Msg)
urlUpdate urlResult model =
    case urlResult of
        Ok slug -> update GetDocument { model | slug = slug }
        Err message -> ({ model | title = "Error", content = message }, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ a [href "#/documentation"] [
            h1 [] [text "bit-lang documentation v0.0"]
          ]
        , mainNav model.mainNav
        , h2 [class "document-title"] [text model.title]
        , div [] [ Markdown.toHtml [] model.content ]
        ]

mainNav items =
    ul [class "top-navigation"]
        (List.map ( \l -> li [] [a [href (toUrl l.slug)] [text l.title]] ) items)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- HTTP
access_token = "eb3f72d5bce55840bd6905e941091ff435d9005d1c29e1906c70ad384e4a2693"
space = "3on7pmzbo8hd"
contentful = "https://cdn.contentful.com/spaces/" ++ space ++ "/"

getDocumentsQuery params =
    Http.url (contentful ++ "entries/") (List.append [("access_token", access_token), ("content_type", "document")] params)

getDocumentRoot : Cmd Msg
getDocumentRoot =
    Task.perform FetchFail FetchSucceed (Http.get queryResultDecoder (getDocumentsQuery [("fields.parent[exists]", "false"), ("include", "0"), ("order", "-fields.version")]))

getNavigation : String -> Cmd Msg
getNavigation rootId =
    Task.perform FetchFail FetchNavigation (Http.get queryResultDecoder (getDocumentsQuery [("fields.parent.sys.id", rootId), ("include", "0")]))

getDocumentBySlug : String -> Cmd Msg
getDocumentBySlug slug =
    Task.perform FetchFail FetchSucceed (Http.get queryResultDecoder (getDocumentsQuery [("fields.slug", slug), ("include", "0"), ("limit", "1")]))


-- JSON decoding
type alias QueryResult = List ResultItem

type alias ResultItem =
    { sys : SysResult
    , fields : FieldsResult }

type alias SysResult =
    { id : String
    }

type alias FieldsResult =
    { title : String
    , slug : String
    , version : String
    , content : String
    }       

queryResultDecoder : Json.Decoder QueryResult
queryResultDecoder =
    Json.at ["items"] (Json.list itemDecoder)

itemDecoder : Json.Decoder ResultItem
itemDecoder =
    Json.object2 ResultItem
        ( "sys" := sysDecoder )
        ( "fields" := fieldsDecoder )

sysDecoder : Json.Decoder SysResult
sysDecoder = Json.object1 SysResult ( "id" := Json.string )

fieldsDecoder : Json.Decoder FieldsResult
fieldsDecoder =
    Json.object4 FieldsResult
        ( "title" := Json.string )
        ( "slug" := Json.string )
        ( "version" := Json.string )
        ( "content" := Json.string )

toModel : ResultItem -> Model
toModel result = Model result.sys.id result.fields.version result.fields.slug result.fields.title result.fields.content []

toNavigationItem : ResultItem -> NavigationItem
toNavigationItem result = NavigationItem result.fields.version result.fields.slug result.fields.title
