{- bitdoc

   This is the main application. Its purpose is to create a showcase application for Elm, and to
   communicate to others how you can build an Elm application.

   In short, this application is a frontend to an CMS called Contentful. It will use the Contentful
   API in order to build a page tree navigation (to the left) and to fetch and display pages that
   are composed through the CMS.
-}

import Html exposing (..) 
import Html.App as App
import Html.Attributes exposing (..)
import Markdown
import Navigation
import Maybe exposing (..)
import String
import Regex exposing (HowMany(..))
import TableOfContents 
import Contentful exposing (Msg(..))
import ContentTree
import Search


{-| main:

    This is the main entry for the application. It uses the Navigation module in order to create
    a default router for SPA applications.
-}
main =
    Navigation.program urlParser
        { init = init 
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }



-----------------------------------------------------------------------------------------
-- URL PARSERS
-----------------------------------------------------------------------------------------

{-| fromUrl:

    Parse the document identifier from the URL, so if the user modifies the URL we can load 
    the appropriate document.

    @url: The url that shall be parsed.
-}
fromUrl : String -> (Maybe String)
fromUrl url = 
    let matches = 
        Regex.find (AtMost 1) (Regex.regex "#\\/(.*)$") url
        |> List.map .submatches
    in (List.head matches) `andThen` List.head
       |> Maybe.withDefault Nothing


{-| urlParser:

    An instance of a parser that will parse the URL.
-}
urlParser : Navigation.Parser (Maybe String)
urlParser = Navigation.makeParser (fromUrl << .hash)



-----------------------------------------------------------------------------------------
-- MODEL
-----------------------------------------------------------------------------------------

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

{-| init:

    Will create a new model and fetch the root page, or page for the slug.

    @urlPart: If the URL parser has been able to parse out a slug, this will be sent here
    as a slug, otherwise Nothing will appear. If we get a slug, that document will be fetched. 
    Otherwise the considered root document (first document with no parent) will be fetched instead.
-}
init : Maybe String -> (Model, Cmd Msg)
init urlPart =
    -- get document root or get document by URL slug
    let getDocument : Cmd Contentful.Msg
        getDocument = 
            case urlPart of
                Just slug -> Contentful.getDocumentBySlug slug
                Nothing -> Contentful.getDocumentRoot

        -- initialize content tree and get the initial document
        (contentTree, contentTreeInit) = ContentTree.init
        cmd = Cmd.batch [ Cmd.map ContentTreeMsg contentTreeInit, Cmd.map ContentfulMsg getDocument ]

    -- initial model before the result from document query comes back
    in ( Model "" "" "documentation" "Loading" "Please wait..." (TableOfContents.init "" "") contentTree (Search.Model "" 0 []), cmd )



-----------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------

{-| Msg:

    @GetDocument: Get a document by slug.

    @ContentfulMsg msg: Handle the result from API queries. When a response comes back, 
    update the model with document data.

    @ContentTreeMsg msg: Handle messages for the left navigation.

    @SearchMsg msg: Handle messages for the search integration.
-}
type Msg
    = GetDocument
    | ContentfulMsg Contentful.Msg
    | ContentTreeMsg ContentTree.Msg
    | SearchMsg Search.Msg


{-| update:

    Will update the model. If the message is to GetDocument, then a document will be fetched
    from the API by the slug. If the message is ContentFulMsg then we need to handle the
    response from the API query. ContentTreeMsg is used to tell the navigation what node in
    the content tree should be marked as active. SearchMsg will happen when you type in the search
    field.

    @msg: The message of what is being updated.

    @model: The model before the update.
-}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    -- take the query result from Contentful and create a model record
    let modelFromResultItem : Model -> Contentful.ResultItem -> Model
        modelFromResultItem model item =
            { model
            | id = item.sys.id
            , version = item.fields.version
            , slug = item.fields.slug
            , title = item.fields.title
            , content = item.fields.content
            , toc = (TableOfContents.init item.fields.title item.fields.content)
            , nav = (fst (ContentTree.update ( ContentTree.Navigate item.fields.slug ) model.nav) )
            , search = (Search.Model "" 0 [])
           }

    in case msg of
            -- fetch new document by slug
            GetDocument ->
                (model, Cmd.map ContentfulMsg (Contentful.getDocumentBySlug model.slug) )

            -- hand response from Contentful Delivery API
            ContentfulMsg subMsg ->
                case subMsg of
                    DocumentQuerySucceed result ->
                        case List.head result of
                            Just item -> ( modelFromResultItem model item, Cmd.none )
                            Nothing -> ( { model 
                                         | title = "Not found"
                                         , content = "The specified document was not found" 
                                         }, Cmd.none )

                    DocumentQueryFail _ ->
                        ( { model 
                          | title = "Error"
                          , content = "Failed to get document from Contentful CMS" 
                          }, Cmd.none )

            -- update the navigation tree with active page
            ContentTreeMsg subMsg ->
                let ( contentTreeModel, contentTreeCmd ) = ContentTree.update subMsg model.nav
                in ( { model | nav = contentTreeModel }, Cmd.map ContentTreeMsg contentTreeCmd )

            -- handle the search query and search result
            SearchMsg subMsg ->
                let (searchModel, searchCmd) = Search.update subMsg model.search 
                in ( { model | search = searchModel }, Cmd.map SearchMsg searchCmd )


{-| urlUpdate:

    This is triggered when the URL is changed. When the URL changes, we parse out the slug
    and if a slug is found, we will try to fetch the document for that slug. If we can't get
    the slug, we will provide an error message.
-}
urlUpdate : (Maybe String) -> Model -> (Model, Cmd Msg)
urlUpdate urlResult model =
    case urlResult of
        Just slug -> update GetDocument { model | slug = slug }
        Nothing -> ({ model | title = "No document found", content = "Failed to parse the URL that would provide a document." }, Cmd.none)



-----------------------------------------------------------------------------------------
-- VIEW
-----------------------------------------------------------------------------------------

{-| view:

    Standard view will output the whole application, mainly in three sections. One left
    column with navigation and search input. A large right column with page header and
    document content.

    @model: The model that should be rendered.
-}
view : Model -> Html Msg
view model =
    -- render the page header
    let pageHeader : List (Html Msg) -> Html Msg
        pageHeader elements =
            header [] 
            ( ( h1 [] [ text "Bit v0.1 Documentation" ] ) :: elements )

        -- render the left column with search and navigation
        leftColumn : Html Msg
        leftColumn =
            div [id "left", class "col-sm-2"]
            [ a [href "#/documentation", class "title"] [text "Bit"]
            , App.map (\msg -> SearchMsg msg) (Search.viewSearchInput model.search)
            , App.map (\msg -> ContentTreeMsg msg) (ContentTree.view model.nav)
            ]

        -- render the search result as a replacement to the right column
        searchResult : Html Msg
        searchResult =
            div [id "right", class "col-sm-10"]
            [ App.map (\msg -> SearchMsg msg) (Search.viewSearchResult model.search)
            ]

        -- render the index view in the right column instead of the document
        index : Html Msg
        index =
            div [id "right", class "col-sm-10"]
            [ pageHeader [ hr [] [] ]
            , h1 [class "document-title"] [text "Index"]
            , div [class "content"] 
              [ App.map (\msg -> ContentTreeMsg msg) (ContentTree.viewIndex model.nav)
              ]
            ]

        -- render the document in the right column
        document : Html Msg
        document =
            div [id "right", class "col-sm-10"]
            [ pageHeader 
              [ a [href "#/index"] [text "Index"]
              , text " | "
              , a [href (Contentful.getDocumentQuery model.id)] [text "View as JSON"]
              , hr [] []
              , h2 [] [text "Table of Contents"]
              , App.map (\_ -> GetDocument) (TableOfContents.view model.toc)
              ]
            , h1 [class "document-title"] [text model.title]
            , div [class "content"] [ Markdown.toHtml [] model.content ]
            ]

    in div [class "main row"]
        [ leftColumn
        , if model.search.count > 0 then 
            -- if search result exchange right column with search result
            searchResult 
          else
            -- render right column as usual
            if model.slug == "index" then
                -- render the index view if document slug is index
                index
             else 
                -- otherwise render the document
                document
        ]

   
-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

