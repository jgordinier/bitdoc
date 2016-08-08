module Contentful exposing (QueryResult, ResultItem, Msg(..), getDocumentQuery, getDocumentRoot, getNavigation, getDocumentBySlug, search)

import Http
import Markdown
import Json.Decode as Json
import Json.Decode exposing ((:=))
import Task exposing (..)

-- MODEL

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
    }       

-- UPDATE

type Msg
    = DocumentQuerySucceed QueryResult
    | DocumentQueryFail Http.Error
    | NavigationQuerySucceed QueryResult
    | NavigationQueryFail Http.Error

-- HTTP
access_token = "eb3f72d5bce55840bd6905e941091ff435d9005d1c29e1906c70ad384e4a2693"
space = "3on7pmzbo8hd"
contentful = "https://cdn.contentful.com/spaces/" ++ space ++ "/"

getDocumentsQuery params =
    Http.url (contentful ++ "entries/") (List.append [("access_token", access_token), ("content_type", "document")] params)

getDocumentQuery id =
    Http.url (contentful ++ "entries/" ++ id) [("access_token", access_token)]

getDocumentRoot : Cmd Msg
getDocumentRoot =
    Task.perform DocumentQueryFail DocumentQuerySucceed (Http.get queryResultDecoder (getDocumentsQuery [("fields.parent[exists]", "false"), ("include", "0"), ("order", "-fields.version")]))

getNavigation : String -> Cmd Msg
getNavigation rootId =
    Task.perform NavigationQueryFail NavigationQuerySucceed (Http.get queryResultDecoder (getDocumentsQuery [("fields.parent.sys.id", rootId), ("include", "0")]))

getDocumentBySlug : String -> Cmd Msg
getDocumentBySlug slug =
    Task.perform DocumentQueryFail DocumentQuerySucceed (Http.get queryResultDecoder (getDocumentsQuery [("fields.slug", slug), ("include", "0"), ("limit", "1")]))

search : String -> Cmd Msg
search query =
    Task.perform DocumentQueryFail DocumentQuerySucceed (Http.get queryResultDecoder (getDocumentsQuery [("query", query), ("include", "0")]))

-- JSON decoding

queryResultDecoder : Json.Decoder QueryResult
queryResultDecoder =
    Json.at ["items"] (Json.list itemDecoder)

itemDecoder : Json.Decoder ResultItem
itemDecoder =
    Json.object2 ResultItem
        ( "sys" := sysDecoder )
        ( "fields" := fieldsDecoder )

sysDecoder : Json.Decoder SysResult
sysDecoder = Json.object1 SysResult ( "id" := Json.string )

fieldsDecoder : Json.Decoder FieldsResult
fieldsDecoder =
    Json.object4 FieldsResult
        ( "title" := Json.string )
        ( "slug" := Json.string )
        ( "version" := Json.string )
        ( "content" := Json.string )


