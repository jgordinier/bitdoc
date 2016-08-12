{- TableOfContents

    Summary: This module will take the Markdown content of a document and build a table
    of contents from its headlines.
-}
module TableOfContents exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Regex exposing (..)
import String



-----------------------------------------------------------------------------------------
-- MODEL
-----------------------------------------------------------------------------------------

type Model = Model (List TocItem)

type alias TocItem =
    { level : Int
    , heading : String
    , slug : String
    , nodes : Model
    }

{-| slugit:

    Create a slug from the title.

    @heading: The heading that should be turned into a slug.
-}
slugit : String -> String
slugit heading = String.toLower (replace All (regex "[^\\w]") (\_ -> "") heading) 

{-| tocify:

    Create a TocItem from heading.

    @level: The level of the heading is determined by the number of `#` in the markdown.

    @heading: The heading that should be turned into a TocItem. This will be cleaned from all
    '#' characters that specify which kind of heading it is.
-}
tocify : Int -> String -> TocItem
tocify level heading =
    TocItem 
        level
        (replace All (regex "^#+\\s+") (\_ -> "") heading)
        (slugit heading) 
        (Model [])

{-| init:

    Create a table of contents from markdown.

    @title: Title needs to be sent separatly as it is not part of the markdown and should be
    the top level item in the table of contents.

    @content: The content in markdown that will be parsed.
-}
init: String -> String -> Model
init title content =
    let titleItem = tocify 1 title
    in Model (parseToModel (parseInput content) titleItem)



-----------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------

{-| parseInput:

    Because Regex in Elm doesn't have multiline option (idiocrazy!) we need to split the
    markdown into lines, and parse each line individually. This function will split the
    markdown into line, and then filter out those that starts with the #-character as
    those are our headlines.

    @input: The markdown that should be parsed.
-}
parseInput : String -> List String
parseInput input =
    String.lines input
    |> List.map (\l -> String.trim l)
    |> List.filter (\l -> String.startsWith "#" l)

{-| getLevel:

    Count the number of #-characters at the beginning of the string. Those represent the
    headline level. One `#` character is level 1 and will translate to h1.
-}
getLevel : String -> Int
getLevel input =
    Regex.find (AtMost 1) (Regex.regex "^#+") input
    |> List.map .match
    |> List.head
    |> Maybe.withDefault ""
    |> String.length

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

{-| splitLevel:

    This will split a list in two parts.
    1. Those that are on a lower level than current level
    2. Those that are on the same level or over current level

    Example

    # Heading 1
    ## Heading 2
    ### Heading 3
    # Heading 4
    ## Heading 5

    Will be split into

    # Heading 1
    ## Heading 2
    ### Heading 3
    --
    # Heading 4
    ## Heading 5

    @level: The current level
    @input: A list of headings still with their `#` characters at the start of the string.
-}
splitLevel : Int -> (List String) -> (List String, List String)
splitLevel level input =
    case List.head input of
        Just first ->
            if (getLevel first) > level then
               let (sub, rest) = splitLevel level (tail input)
               in ((first :: sub), rest)
            else
               ([], input)
        Nothing -> ([], [])

{-| parseToModel:

    Take the list of headings and turn it into a recursive TocItem tree structure.

    @input: A list of headings still with their `#` characters at the start of the string.

    @parent: The current TocItem that child heading should be apended to. This is the title
    of the document in the first call.
-}
parseToModel : (List String) -> TocItem -> (List TocItem)
parseToModel input parent =
    let (sub, rest) = splitLevel parent.level input
        
        parse : (List String) -> List TocItem 
        parse list =
            case List.head list of
                Just first -> parseToModel (tail list) (tocify (getLevel first) first)
                Nothing -> []

    in { parent | nodes = Model (parse sub) } :: parse rest



-----------------------------------------------------------------------------------------
-- VIEW
-----------------------------------------------------------------------------------------

{-| unbox:

    A function to make the Model into a List so we can iterate over it.

    @model: The model that should be returned as a list.
-}
unbox : Model -> List TocItem
unbox model =
    case model of Model m -> m

{-| view:

    The default view to render is a recursive ui/li list.

    @model: The model that should be rendered.
-}
view : Model -> Html String
view model =
    ul [class "toc"] (List.map renderToc (unbox model))
        

{-| renderToc:

    Render an individual table of contents item and its subitems.

    @item: Table of contents item to render.
-}
renderToc : TocItem -> Html String
renderToc item =
        li [] [ text item.heading, ul [] (List.map renderToc (unbox item.nodes)) ]
