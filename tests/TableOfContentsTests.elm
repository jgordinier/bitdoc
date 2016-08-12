module TableOfContentsTests exposing (all)

import Test exposing (..)
import Expect exposing (..)
import String
import Fuzz exposing (string)
import TableOfContents exposing (..)
import Regex

-- ASSERTIONS

notMatch : String -> String -> Expectation
notMatch expression input =
    case Regex.contains (Regex.regex expression) input of
        True -> Expect.fail ("The input " ++ input ++ " shouldn't match the expression " ++ expression)
        False -> Expect.pass



-- TESTS

all : Test
all =
    describe "The TableOfContents module"
        [ slugit
        , tocify
        , parseInput
        , getLevel
        , tail
        , splitLevel
        , parseToModel
        , unbox
        ]

slugit : Test
slugit =
    describe "TableOfContents.slugit"
        [ fuzz string "will take any identifier and only return letters and numbers" <|
            \identifier ->
                identifier
                |> TableOfContents.slugit
                |> notMatch "[^\\w]"
        ]

tocify : Test
tocify =
    describe "TableOfContents.tocify"
        [ describe "creates a new TocItem that"
            [ test "removes the # characters from the heading" <|
                \() ->
                    let input = "### This is my subtitle"
                        expected = "This is my subtitle"
                    in Expect.equal expected (TableOfContents.tocify 1 input).heading

            , test "creates a slug from the heading" <|
                \() ->
                    let input = "### This is my subtitle"
                        expected = "thisismysubtitle"
                    in Expect.equal expected (TableOfContents.tocify 1 input).slug

            , test "initializes with an empty model of nodes" <|
                \() ->
                    Expect.equal (Model []) (TableOfContents.tocify 1 "Test").nodes
            ]
        ]

markdown = """# This is the main markdown file.

It can contain a lot of content, and also [inline links](http://#tjoho) that the parser should not care about. The important part is that all the headings are parsed out.

> Here follows a disposition of what this document could become.

## How to do the parsing without any errors
### Watch out for false positives
### Watch out for true falsitives
# How to deal with the `#` character
## Make sure the content is not affected

TODO: Make this even more grand later.
"""

parseInput : Test
parseInput =
    describe "TableOfContents.parseInput"
        [ test "splits the markdown content into lines and filter out the headings" <|
            \() -> Expect.equal 6 (List.length (TableOfContents.parseInput markdown))
        ]

getLevel : Test
getLevel =
    describe "TableOfContents.getLevel"
        [ test "returns the number of # characters the string starts with" <|
            \() ->
                let input = "### This is my third sublevel"
                    expected = 3
                in Expect.equal expected (TableOfContents.getLevel input)

        , test "will ignore # characters not in the start of the string" <|
            \() -> 
                let input = "### This is my third sublevel #"
                    expected = 3
                in Expect.equal expected (TableOfContents.getLevel input)

        , test "zero is the least optimal, but possible level" <|
            \() ->
                let input = "This is not a heading at all"
                    expected = 0
                in Expect.equal expected (TableOfContents.getLevel input)
        ]

tail : Test
tail =
    describe "TableOfContents.tail"
        [ test "returns the rest of the list, the head element removed" <|
            \() ->
                let input = [1, 2, 3, 4, 5]
                    expected = [2, 3, 4, 5]
                in Expect.equal expected (TableOfContents.tail input)

        , test "returns an empty list when the input list is empty instead of (Maybe List a)" <|
            \() -> Expect.equal [] (TableOfContents.tail [])
        ]

splitLevel : Test
splitLevel =
    describe "TableOfContents.splitLevel"
        [ describe "split a list of headings on their level"
            [ test "first result is headings that are below current level" <|
                \() ->
                    let level = 1
                        input = TableOfContents.parseInput """
                            ## Heading 2
                            ### Heading 3
                            # Heading 4
                            ## Heading 5"""
                        expected = ["## Heading 2", "### Heading 3"]
                    in Expect.equal expected ( fst (TableOfContents.splitLevel 1 input  ) )

            , test "second result is headings that are not below current level" <| 
                \() ->
                    let level = 1
                        input = TableOfContents.parseInput """
                            ## Heading 2
                            ### Heading 3
                            # Heading 4
                            ## Heading 5"""
                        expected = ["# Heading 4", "## Heading 5"]
                    in Expect.equal expected ( snd (TableOfContents.splitLevel 1 input ) )
            ]
        ]

parseToModel : Test
parseToModel =
    describe "TableOfContents.parseToModel"
        [ test "turn a list of headings into a recursive tree of TocItem" <|
            \() ->
                let input =
                    [ "## Heading 2"
                    , "### Heading 3"
                    , "# Heading 4"
                    , "## Heading 5"
                    ]
                    parent = TableOfContents.tocify 1 "# Heading 1"
                    expected =
                        [ TableOfContents.TocItem 1 "Heading 1" "heading1"
                            ( Model [ TableOfContents.TocItem 2 "Heading 2" "heading2"
                                        ( Model [ TableOfContents.TocItem 3 "Heading 3" "heading3" (Model [])
                                                ]
                                        )
                                    ]
                            )
                        , TableOfContents.TocItem 1 "Heading 4" "heading4"
                            ( Model [ TableOfContents.TocItem 2 "Heading 5" "heading5" (Model [])
                                    ]
                            )
                        ]

                in Expect.equal expected ( TableOfContents.parseToModel input parent )
        ]

unbox : Test
unbox =
    describe "TableOfContents.unbox"
        [ test "turn the model into a List TocItem so we can iterate over it" <|
            \() ->
                let input =
                    Model 
                        [ TableOfContents.tocify 1 "# Heading 1"
                        , TableOfContents.tocify 2 "## Heading 2"
                        ]
                    expected =
                        [ TableOfContents.tocify 1 "# Heading 1"
                        , TableOfContents.tocify 2 "## Heading 2"
                        ]
                in Expect.equal expected ( TableOfContents.unbox input )
        ]
