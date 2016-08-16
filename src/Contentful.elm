{- Contentful

   Summary: This module will provide easy access to the Contentful API, parsing the result and
   present it in an accessible way to consumers.
-}
module Contentful exposing 
    ( QueryResult
    , ResultItem
    , FieldsResult
    , SysResult
    , Msg(..)
    , getDocumentsQuery
    , getDocumentQuery
    , getDocumentRoot
    , getNavigationTree
    , getDocumentBySlug
    , search
    , queryResultDecoder
    )

import Http
import Json.Decode as Json
import Json.Decode exposing ((:=))
import Task exposing (..)



-----------------------------------------------------------------------------------------
-- MODEL
-----------------------------------------------------------------------------------------

{-| QueryResult:

    This type represents the JSON structure that is returned from the Contentful API.
-}
type alias QueryResult = List ResultItem

type alias ResultItem =
    { sys : SysResult
    , fields : FieldsResult }

type alias SysResult =
    { id : String
    }

type alias FieldsResult =
    { title : String
    , slug : String
    , version : String
    , content : String
    , parent : Maybe SysResult
    }       



-----------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------

{-| Msg:

    @DocumentQuerySucceed result: This is the message when a result is returned from Contentful
    and successfully parsed into the type structure.

    @DocumentQueryFail error: This is the message when there is an error in running the query
    against the Contentful API. For instance when the API fail to respond.
-}
type Msg
    = DocumentQuerySucceed QueryResult
    | DocumentQueryFail Http.Error



-----------------------------------------------------------------------------------------
-- HTTP
-----------------------------------------------------------------------------------------

{-| @access_token: the public access token for fetching content from the Content Delivery API
-}
access_token = "eb3f72d5bce55840bd6905e941091ff435d9005d1c29e1906c70ad384e4a2693"

{-| @space: the application defined in Contentful that all the content and content types belongs to.
-}
space = "3on7pmzbo8hd"

{-| @contentful: The url to the Content Delivery API including the space.
-}
contentful = "https://cdn.contentful.com/spaces/" ++ space ++ "/"

{-| getDocumentsQuery:

    Constructs a query URL from the base url, access_token and content_type to Contentful Delivery API 
    and append parameters to construct the query.

    @params: The parameters that makes up the query.
-}
getDocumentsQuery : (List (String, String)) -> String
getDocumentsQuery params =
    Http.url (contentful ++ "entries/") (List.append [("access_token", access_token), ("content_type", "document")] params)

{-| getDocumentQuery:

    Get URL to a single document from Contentful Delivery API. This is used in the application
    when you click on 'View as JSON' link for a page.

    @id: The id of a content item (page).
-}
getDocumentQuery id =
    Http.url (contentful ++ "entries/" ++ id) [("access_token", access_token)]

{-| getDocumentRoot:

    Query the Contentful Delivery API to get all pages that has no parent page set.
-}
getDocumentRoot : Cmd Msg
getDocumentRoot =
    Task.perform DocumentQueryFail DocumentQuerySucceed (Http.get queryResultDecoder (getDocumentsQuery [("fields.parent[exists]", "false"), ("include", "0"), ("order", "-fields.version")]))

{-| getNavigationTree:

    Will query the Contentful Delivery API to get all pages. From this result a navigation tree
    can be built by looking at the parent-field of each page.
-}
getNavigationTree : Cmd Msg
getNavigationTree =
    Task.perform DocumentQueryFail DocumentQuerySucceed (Http.get queryResultDecoder (getDocumentsQuery [("include", "0")]))

{-| getDocumentBySlug:

    Use the slug from the URL to query the Content Delivery API for a matching document. Navigation
    is done this way.

    @slug: The slug that we will query documents for.
-}
getDocumentBySlug : String -> Cmd Msg
getDocumentBySlug slug =
    Task.perform DocumentQueryFail DocumentQuerySucceed (Http.get queryResultDecoder (getDocumentsQuery [("fields.slug", slug), ("include", "0"), ("limit", "1")]))

{-| search

    Full text search for documents. This is used by the search functionality.

    @query: The search query that we're looking for.
-}
search : String -> Cmd Msg
search query =
    Task.perform DocumentQueryFail DocumentQuerySucceed (Http.get queryResultDecoder (getDocumentsQuery [("query", query), ("include", "0")]))



-----------------------------------------------------------------------------------------
-- JSON decoding
-----------------------------------------------------------------------------------------

{-| queryResultDecoder:

    Will take the result from Contentful Delivery API and parse all the JSON items to statically
    typed ResultItems.
-}
queryResultDecoder : Json.Decoder QueryResult
queryResultDecoder =
    Json.at ["items"] (Json.list itemDecoder)

{-| itemDecoder:

    An item in the JSON output is divided into two parts, sys and fields. These parts needs to
    be parsed separatly.
-}
itemDecoder : Json.Decoder ResultItem
itemDecoder =
    Json.object2 ResultItem
        ( "sys" := sysDecoder )
        ( "fields" := fieldsDecoder )

{-| sysDecoder:

    The sys object in the result JSON only has one field that we're interested in right now
    and that is the `id`.
-}
sysDecoder : Json.Decoder SysResult
sysDecoder = Json.object1 SysResult ( "id" := Json.string )

{-| fieldsDecoder:

    The fields object in the result JSON contains all the data for our document. From here
    we extract title, slug, version and content. If parent has been set, it will be another
    nexted sys object.
-}
fieldsDecoder : Json.Decoder FieldsResult
fieldsDecoder =
    Json.object5 FieldsResult
        ( "title" := Json.string )
        ( "slug" := Json.string )
        ( "version" := Json.string )
        ( "content" := Json.string )
        ( Json.maybe ( "parent" := Json.at ["sys"] sysDecoder ) )

