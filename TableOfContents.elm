module TableOfContents exposing (Model, TocItem, init, view)

import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Regex exposing (..)
import String

-- MODEL

type Model = Model (List TocItem)

type alias TocItem =
    { level : Int
    , heading : String
    , slug : String
    , nodes : Model
    }

slugit : String -> String
slugit heading = String.toLower (replace All (regex "[^\\w]") (\_ -> "") heading) 

tocify : Int -> String -> TocItem
tocify level heading =
    TocItem 
        level 
        (replace All (regex "^#+\\s+") (\_ -> "") heading)
        (slugit heading) 
        (Model [])

init: String -> String -> Model
init rootHeading content =
    let root = tocify 1 rootHeading
    in Model (parseToModel (parseInput content) root)


{-
Use this to annotate the HTML to match the table of contents
annotate : Html a -> Html a
annotate node =
    case node.tag of
        "h1" -> { node | children = (a [name "headline"] [text "#"]) :: node.children }
        "h2" -> { node | children = (a [name "headline"] [text "#"]) :: node.children }
        -- and so on...
        _ -> { node | children = List.map annotate node.children }

-}

-- UPDATE

parseInput : String -> List String
parseInput input =
    -- can't use regex because of multiline option is missingin Elm
    String.lines input
    |> List.map (\l -> String.trim l)
    |> List.filter (\l -> String.startsWith "#" l)

getLevel : String -> Int
getLevel input =
    List.length (String.indexes "#" input)

-- this is stupid, I don't care about Maybe, just give me an empty list if there is no tail
listTail : (List String) -> (List String)
listTail input =
    case List.tail input of
        Just l -> l
        Nothing -> []

-- Split list in two
-- #1 those under this section
-- #2 the rest
splitLevel : Int -> (List String) -> (List String, List String)
splitLevel level input =
    case List.head input of
        Just first ->
            if (getLevel first) > level then
               let (sub, rest) = splitLevel level (listTail input)
               in ((first :: sub), rest)
            else
               ([], input)
        Nothing -> ([], [])

parseToModel : (List String) -> TocItem -> (List TocItem)
parseToModel input parent =
    let (sub, tail) = splitLevel parent.level input
        
        parse : (List String) -> List TocItem 
        parse list =
            case List.head list of
                Just first -> parseToModel (listTail list) (tocify (getLevel first) first)
                Nothing -> []

    in { parent | nodes = Model (parse sub) } :: parse tail

-- VIEW

unbox : Model -> List TocItem
unbox model =
    case model of Model m -> m

view : Model -> Html String
view model =
    ul [class "toc"] (List.map renderToc (unbox model))
        

renderToc : TocItem -> Html String
renderToc m =
        li [] [ text m.heading, ul [] (List.map renderToc (unbox m.nodes)) ]
