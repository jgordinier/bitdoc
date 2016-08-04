module TableOfContents exposing (Model, TocItem, Msg, init, update, view, parseInput)

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

tocify : Int -> String -> TocItem
tocify level heading =
    TocItem 
        level 
        (replace All (regex "^#+\\s+") (\_ -> "") heading)
        (replace All (regex "[^\\w]") (\_ -> "") heading) 
        (Model [])

init: String -> String -> Model
init rootHeading content =
    let root = tocify 1 rootHeading
    in Model (parseToModel (parseInput content) root)

-- UPDATE

type Msg = String

update : String -> TocItem -> Model
update msg model = 
    Model (parseToModel (parseInput msg) model)

{- Accepts a markdown string and results a list like this
   # Top heading
   ## Section heading
   ### Sub heading
   ### Sub heading
   ## Section heading
   ## Section heading
   ### Sub heading
   # Top heading
-}
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

view : Model -> Html Msg
view model =
    ul [class "toc"] (List.map renderToc (unbox model))
        

renderToc : TocItem -> Html Msg
renderToc m =
        li [] [ a [href m.slug] [text m.heading], ul [] (List.map renderToc (unbox m.nodes)) ]
