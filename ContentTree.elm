{- ContentTree
   
   Summary: This module will load all pages from Contentful and generate a page tree view.
   The page tree will be used for generating a left side navigation and page index.

-}
module ContentTree exposing 
    ( Model
    , NavigationItem
    , Msg(Navigate)
    , init
    , update
    , view
    , viewIndex
    )

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Contentful exposing (Msg(DocumentQuerySucceed, DocumentQueryFail))



-----------------------------------------------------------------------------------------
-- MODEL
-----------------------------------------------------------------------------------------

type Model = Model (List NavigationItem)

type alias NavigationItem =
    { id : String
    , slug : String
    , title : String
    , active : Bool
    , children : Model
    }


{-| unbox:
    
    Will take a model and unbox it to a (List NavigationItem). This is neccessary when we want to
    process the model as a list.

-}
unbox : Model -> List NavigationItem
unbox model = case model of Model m -> m


{-| init:

    Will create a new model and fetch the page tree from Contentful API.

-}
init : (Model, Cmd Msg)
init = (Model [], Cmd.map SubMsg Contentful.getNavigationTree)



-----------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------

{-| Msg:

    @Navigate slug: Will tell this module what slug is being navigated to. This is useful for marking
    that navigation item as active.

    @SubMg Contentful.Msg: The result that comes back from Contentful API. It can be succeed or fail.
-}
type Msg
    = Navigate String
    | SubMsg Contentful.Msg

{-| update:

    Will update the model. If the message is Navigate, the active navigation item will be marked
    as active. If the message is SubMsg then the model will be replaced by new result from Contentful.

    @msg: The message of what is being updated.

    @model: The model before the update.
-}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Navigate slug ->
            ( setActive slug model, Cmd.none )
        SubMsg subMsg ->
            case subMsg of
                DocumentQuerySucceed result ->
                    ( buildContentTree result, Cmd.none )
                DocumentQueryFail _ ->
                    ( model, Cmd.none )


{-| tail:

    Utility function. List.tail will return (Maybe List a) where I prefer if it would just 
    return List a. This would make it easier to do (car :: cdr) pattern matching.

    @list: Return the rest of the list. Empty list if the list is empty.
-}
tail : List a -> List a
tail list =
    case List.tail list of
        Just l -> l
        Nothing -> []


{-| setActive:

    Will traverse the tree and find the navigation item that has the navigated slug, and change
    property `active` to True.

    @slug: The slug that should be set active.

    @model: The model that should be traversed.
-}
setActive : String -> Model -> Model
setActive slug model =
    let setActive' : List NavigationItem -> List NavigationItem
        setActive' navItems =
            case List.head navItems of
                Just head -> { head | active = ( head.slug == slug ), children = Model ( setActive' ( unbox head.children ) ) } :: ( setActive' ( tail navItems ) )
                Nothing -> []

    in Model ( setActive' ( unbox model ) )

{-| buildContentTree:

    Create a model from a QueryResult. The QueryResult is a flat list where pages with parent references
    should be added as sub pages. Pages with no parent should be top level pages.

    @result: The query result from the Contentful API query.
-}
buildContentTree : Contentful.QueryResult -> Model
buildContentTree result =

    -- filterParent:
    {-
        Get all pages from result with a specific parent. Use this to find children for pages.

        @id: The id of the parent that we want to find children for. Could be `Nothing` for 
        pages in the top level.
    -}
    let filterParent : (Maybe String) -> (List Contentful.ResultItem)
        filterParent id =
            let sys =
                case id of
                    Just id' -> Just { id = id' }
                    Nothing -> Nothing
            in List.filter (\item -> item.fields.parent == sys) result
       
        --| toNavigationItem:
        {-
            Create a new NavigationItem from a Contentful.ResultItem

            @result: The Contentful.ResultItem that should be turned into a NavigationItem.
        -}
        toNavigationItem : Contentful.ResultItem -> NavigationItem
        toNavigationItem result =
            NavigationItem result.sys.id result.fields.slug result.fields.title False (Model [])


        --| buildContentTree':
        {-
            Build a recursive navigation tree out of a flat query result structure, using document
            parent references.

            @list: A list of NavigationItem that has already been parsed. For each item in the list
            the function will resolve their children by looking for documents in the result with
            parent references to these items.
        -}
        buildContentTree' : (List NavigationItem) -> (List NavigationItem)
        buildContentTree' list =
            case List.head list of
                Just head -> { head | children = Model ( buildContentTree' (List.map toNavigationItem (filterParent (Just head.id) ) ) ) } :: (buildContentTree' (tail list) ) 
                Nothing -> []

        --| rootDocuments:
        {-
        Get all documents that doesn't have a parent. These are the top level navigation.
        -}
        rootDocuments : (List NavigationItem)
        rootDocuments = List.map toNavigationItem (filterParent Nothing)

    in Model (buildContentTree' rootDocuments)



-----------------------------------------------------------------------------------------
-- VIEW
-----------------------------------------------------------------------------------------

{-| role:

    Create a role attribute for HTML elements, like <nav role="navigation">..</nav>

    @identifier: The value of the role attribute.
-}
role : String -> Attribute msg
role identifier =
    attribute "role" identifier

{-| view:

    Standard view will ouput a nav element with the navigation inside it.

    @model: The model that should be rendered.
-}
view : Model -> Html Msg
view model =
        -- ul navigation list
    let viewNavigation : Model -> Html Msg
        viewNavigation model =
            ul [class "nav nav-stacked"] (List.map viewNavigationItem (unbox model))

        -- li navigation item
        viewNavigationItem item =
            li [role "presentation", class (if item.active then "active" else "")] 
            [ a [ href ("#/" ++ item.slug) ] [ text item.title ]
            , viewNavigation item.children
            ]

    in nav [role "navigation"] [viewNavigation model]


{-| viewIndex:

    Used to render an index. This is very much like the navigation but it shouldn't have the
    Bootstrap classes for navigation.

    @model: The model that should be rendered.
-}
viewIndex : Model -> Html Msg
viewIndex model =
    let viewIndex' : Model -> Html Msg
        viewIndex' model =
            ul [] (List.map viewIndexItem (unbox model))

        viewIndexItem item =
            li [] [ a [ href ("#/" ++ item.slug) ] [ text item.title ], viewIndex' item.children ]

    in div [class "index"] [viewIndex' model]
