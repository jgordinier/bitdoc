import Html exposing (..) 
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation
import String
import TableOfContents exposing (..)
import Contentful exposing (..)

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
    }

type alias Navigation = List NavigationItem

type alias NavigationItem =
    { version: String
    , slug : String
    , title : String
    }       

toModel : ResultItem -> Model
toModel result = Model result.sys.id result.fields.version result.fields.slug result.fields.title result.fields.content (TableOfContents.init result.fields.title result.fields.content) [] []

toNavigationItem : ResultItem -> NavigationItem
toNavigationItem result = NavigationItem result.fields.version result.fields.slug result.fields.title

init : Result String String -> (Model, Cmd Msg)
init slug =
    ( Model "" "" "" "Loading" "Please wait..." (TableOfContents.init "" "") [] [], getDocumentRoot )

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
                             in ( { newModel | mainNav = model.mainNav, subNav = model.subNav }, getNavigation newModel.id )
                Nothing -> (Model model.id model.version model.slug "Not found" "The specified document was not found" model.toc model.mainNav model.subNav, Cmd.none)

        FetchNavigation queryResult ->
            let newMenu = List.map toNavigationItem queryResult
            in
                if List.isEmpty queryResult then
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
    div [class "main row"]
        [ div [id "left", class "col-sm-2"]
              [ a [href "#/documentation", class "title"] [text "Bit"]
              , navigation "main-navigation" model.mainNav
              , navigation "sub-navigation" model.subNav
              ]
        , div [id "right", class "col-sm-10"]
              [ header []
                [ h1 [] [text "Bit v0.1 Documentation"]
                , a [href "#/index"] [text "Index"]
                , text " | "
                , a [href (getDocumentQuery model.id)] [text "View as JSON"]
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

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

