import Html exposing (..) 
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Markdown
import Navigation
import String
import TableOfContents exposing (..)
import Contentful exposing (..)
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
    , toc : TableOfContents.Model
    , mainNav : Navigation
    , subNav : Navigation
    , search : Search.Model
    }

type alias Navigation = List NavigationItem

type alias NavigationItem =
    { version: String
    , slug : String
    , title : String
    }       

toModel : ResultItem -> Model
toModel result = Model result.sys.id result.fields.version result.fields.slug result.fields.title result.fields.content (TableOfContents.init result.fields.title result.fields.content) [] [] (Search.Model "" 0 [])

toNavigationItem : ResultItem -> NavigationItem
toNavigationItem result = NavigationItem result.fields.version result.fields.slug result.fields.title

init : Result String String -> (Model, Cmd Msg)
init slug =
    ( Model "" "" "" "Loading" "Please wait..." (TableOfContents.init "" "") [] [] (Search.Model "" 0 []), Cmd.map ContentfulMsg getDocumentRoot )

-- UPDATE

type Msg
    = GetDocument
    | ContentfulMsg Contentful.Msg
    | SearchMsg Search.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetDocument ->
            (model, Cmd.map ContentfulMsg (Contentful.getDocumentBySlug model.slug) )

        ContentfulMsg subMsg ->
            ( contentfulUpdateHelper model subMsg )

        SearchMsg subMsg ->
            let (searchModel, searchCmd) = Search.update subMsg model.search 
            in ( { model | search = searchModel }, Cmd.map SearchMsg searchCmd )

contentfulUpdateHelper : Model -> Contentful.Msg -> (Model, Cmd Msg)
contentfulUpdateHelper model msg =
    case msg of
        DocumentQuerySucceed result ->
            case List.head result of
                Just item -> let newModel = toModel item
                             in ( { newModel | mainNav = model.mainNav, subNav = model.subNav }, Cmd.map ContentfulMsg (Contentful.getNavigation newModel.id) )
                Nothing -> ( { model | title = "Not found", content = "The specified document was not found" }, Cmd.none )

        DocumentQueryFail _ ->
            ( model, Cmd.none )

        NavigationQuerySucceed result ->
            let newMenu = List.map toNavigationItem result
            in
                if List.isEmpty result then
                   -- do not clear sub menu when there is no further sub navigation
                   ( model, Cmd.none )

                else
                    if List.isEmpty model.mainNav then
                        -- first populate the main nav before populating sub nav
                        ( { model | mainNav = newMenu }, Cmd.none )
                    else
                        if newMenu == model.mainNav then
                           -- do not populate sub nav with same content as in main nav
                           ( { model | subNav = [] }, Cmd.none )
                        else
                            -- all first level navigations should display their sub pages in sub nav
                            ( { model | subNav = newMenu }, Cmd.none )

        NavigationQueryFail _ ->
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
              , navigation "main-navigation" model.mainNav
              , navigation "sub-navigation" model.subNav
              ]
        , if model.search.count > 0 then
             div [id "right", class "col-sm-10"]
             [ viewSearchResult model.search
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

navigation className items =
    let hidden = if (List.isEmpty items) then " hidden" else ""
    in ul [class (className ++ " nav nav-stacked" ++ hidden)]
        (List.map ( \l -> li [] [a [href (toUrl l.slug)] [text l.title]] ) items)

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

