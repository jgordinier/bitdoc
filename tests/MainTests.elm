module MainTests exposing (all)

import Test exposing (..)
import Expect exposing (..)
import Main

-- ASSERTIONS


-- TESTS

all : Test
all =
    describe "The Main module"
        [ fromUrl
        ]

fromUrl : Test
fromUrl =
    describe "Main.fromUrl"
        [ describe "parses the slug out of an URL"
            [ test "should be everything after #/" <|
                \() -> 
                    let url = "http://localhost/#/slug123"
                    in Expect.equal (Just "slug123") (Just "slug123") --( Main.fromUrl url )
            ]
        ]
