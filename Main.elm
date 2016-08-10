import Html exposing (..) 
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Markdown
import Navigation
import String
import TableOfContents exposing (..)
import Contentful exposing (..)
import ContentTree
import Search

main =
    Navigation.program urlParser
        { init = init 
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }

-- URL PARSERS

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
    , toc : TableOfContents.Model
    , nav : ContentTree.Model
    , search : Search.Model
    }

init : Result String String -> (Model, Cmd Msg)
init slug =
    let (contentTree, contentTreeInit) = ContentTree.init
        cmd = Cmd.batch [ Cmd.map ContentTreeMsg contentTreeInit, Cmd.map ContentfulMsg getDocumentRoot ]

    in ( Model "" "" "documentation" "Loading" "Please wait..." (TableOfContents.init "" "") contentTree (Search.Model "" 0 []), cmd )

-- UPDATE

type Msg
    = GetDocument
    | ContentfulMsg Contentful.Msg
    | ContentTreeMsg ContentTree.Msg
    | SearchMsg Search.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetDocument ->
            (model, Cmd.map ContentfulMsg (Contentful.getDocumentBySlug model.slug) )

        ContentfulMsg subMsg ->
            ( contentfulUpdateHelper model subMsg )

        ContentTreeMsg subMsg ->
            let ( contentTreeModel, contentTreeCmd ) = ContentTree.update subMsg model.nav
            in ( { model | nav = contentTreeModel }, Cmd.map ContentTreeMsg contentTreeCmd )

        SearchMsg subMsg ->
            let (searchModel, searchCmd) = Search.update subMsg model.search 
            in ( { model | search = searchModel }, Cmd.map SearchMsg searchCmd )

contentfulUpdateHelper : Model -> Contentful.Msg -> (Model, Cmd Msg)
contentfulUpdateHelper model msg =
    case msg of
        DocumentQuerySucceed result ->
            case List.head result of
                Just item -> ( { model
                                | id = item.sys.id
                                , version = item.fields.version
                                , slug = item.fields.slug
                                , title = item.fields.title
                                , content = item.fields.content
                                , toc = (TableOfContents.init item.fields.title item.fields.content)
                                , nav = (fst (ContentTree.update ( ContentTree.Navigate item.fields.slug ) model.nav) )
                                , search = (Search.Model "" 0 [])
                               }, Cmd.none 
                             )
                
                Nothing -> ( { model | title = "Not found", content = "The specified document was not found" }, Cmd.none )

        DocumentQueryFail _ ->
            ( model, Cmd.none )

urlUpdate : (Result String String) -> Model -> (Model, Cmd Msg)
urlUpdate urlResult model =
    case urlResult of
        Ok slug -> update GetDocument { model | slug = slug }
        Err message -> ({ model | title = "Error", content = message }, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
    div [class "main row"]
        [ div [id "left", class "col-sm-2"]
              [ a [href "#/documentation", class "title"] [text "Bit"]
              , viewSearchInput model.search
              , viewNavigation model.nav
              ]
        , if model.search.count > 0 then
             div [id "right", class "col-sm-10"]
             [ viewSearchResult model.search
             ]
          else
              if model.slug == "index" then
                 div [id "right", class "col-sm-10"]
                 [ header []
                    [ h1 [] [text "Bit v0.1 Documentation"]
                    , hr [] []
                    ]
                 , h1 [class "document-title"] [text "Index"]
                 , div [class "content"] [ viewIndex model.nav ]
                 ]
                    
              else 
                  div [id "right", class "col-sm-10"]
                  [ header []
                    [ h1 [] [text "Bit v0.1 Documentation"]
                    , a [href "#/index"] [text "Index"]
                    , text " | "
                    , a [href (Contentful.getDocumentQuery model.id)] [text "View as JSON"]
                    , hr [] []
                    , h2 [] [text "Table of Contents"]
                    , viewTableOfContents model.toc
                    ]
                  , h1 [class "document-title"] [text model.title]
                  , div [class "content"] [ Markdown.toHtml [] model.content ]
                  ]
        ]

viewIndex nav =
    App.map (\msg -> ContentTreeMsg msg) (ContentTree.viewIndex nav)

viewNavigation nav =
    App.map (\msg -> ContentTreeMsg msg) (ContentTree.view nav)

viewTableOfContents : TableOfContents.Model -> Html Msg
viewTableOfContents model =
    App.map (\_ -> GetDocument) (TableOfContents.view model)

viewSearchInput : Search.Model -> Html Msg
viewSearchInput model =
    App.map (\msg -> SearchMsg msg) (Search.viewSearchInput model)

viewSearchResult : Search.Model -> Html Msg
viewSearchResult model =
    App.map (\msg -> SearchMsg msg) (Search.viewSearchResult model)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

