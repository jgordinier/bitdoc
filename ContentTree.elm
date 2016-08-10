module ContentTree exposing (Model, NavigationItem, Msg(Navigate), init, update, view, viewIndex)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Contentful exposing (Msg(DocumentQuerySucceed, DocumentQueryFail))

main =
    App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type Model = Model (List NavigationItem)

type alias NavigationItem =
    { id : String
    , slug : String
    , title : String
    , active : Bool
    , children : Model
    }

unbox : Model -> List NavigationItem
unbox model = case model of Model m -> m

init : (Model, Cmd Msg)
init = (Model [], Cmd.map SubMsg Contentful.getNavigationTree)

-- UPDATE

type Msg
    = Navigate String
    | SubMsg Contentful.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Navigate slug ->
            ( setActive slug model, Cmd.none )
        SubMsg subMsg ->
            ( updateHelper model subMsg )

updateHelper : Model -> Contentful.Msg -> (Model, Cmd Msg)
updateHelper model msg =
    case msg of
        DocumentQuerySucceed result ->
            ( buildContentTree result, Cmd.none )
        DocumentQueryFail _ ->
            ( model, Cmd.none )

setActive : String -> Model -> Model
setActive slug model =
    let setActive' : List NavigationItem -> List NavigationItem
        setActive' navItems =
            case List.head navItems of
                Just head -> { head | active = ( head.slug == slug ), children = Model ( setActive' ( unbox head.children ) ) } :: ( setActive' ( tail navItems ) )
                Nothing -> []

    in Model ( setActive' ( unbox model ) )

toNavigationItem : Contentful.ResultItem -> NavigationItem
toNavigationItem result =
    NavigationItem result.sys.id result.fields.slug result.fields.title False (Model [])

filterParent : (Maybe String) -> Contentful.QueryResult -> (List Contentful.ResultItem)
filterParent id result =
    let sys =
        case id of
            Just id' -> Just { id = id' }
            Nothing -> Nothing
    in List.filter (\item -> item.fields.parent == sys) result

tail : List a -> List a
tail list =
    case List.tail list of
        Just l -> l
        Nothing -> []

buildContentTree : Contentful.QueryResult -> Model
buildContentTree result =
    let buildContentTree' : (List NavigationItem) -> Contentful.QueryResult -> (List NavigationItem)
        buildContentTree' list result =
            case List.head list of
                Just head -> { head | children = Model ( buildContentTree' (List.map toNavigationItem (filterParent (Just head.id) result) ) result ) } :: (buildContentTree' (tail list) result) 
                Nothing -> []

        rootDocument : Contentful.QueryResult -> (List NavigationItem)
        rootDocument result =
            -- first without a parent
            case List.head (filterParent Nothing result) of
                Just root -> [ toNavigationItem root ]
                Nothing -> []

    in Model (buildContentTree' (rootDocument result) result)

-- VIEW

role : String -> Attribute msg
role identifier =
    attribute "role" identifier

view : Model -> Html Msg
view model =
    nav [role "navigation"] [viewNavigation model]

viewNavigation : Model -> Html Msg
viewNavigation model =
    ul [class "nav nav-stacked"] (List.map viewNavigationItem (unbox model))

viewNavigationItem item =
    li [role "presentation", class (if item.active then "active" else "")] 
    [ a [ href ("#/" ++ item.slug) ] [ text item.title ]
    , viewNavigation item.children
    ]

viewIndex : Model -> Html Msg
viewIndex model =
    let viewIndex' : Model -> Html Msg
        viewIndex' model =
            ul [] (List.map viewIndexItem (unbox model))

        viewIndexItem item =
            li [] [ a [ href ("#/" ++ item.slug) ] [ text item.title ], viewIndex' item.children ]

    in div [class "index"] [viewIndex' model]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
