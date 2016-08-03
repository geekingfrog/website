module Parse exposing (..)

import Json.Decode as Json exposing (..)
import ISO8601 as ISO
import Time as Time

import Types exposing (Post)

decodeAllPosts : Json.Decoder (List Post)
decodeAllPosts = Json.at ["posts"] (Json.list decodePost)


decodeOnePost : Json.Decoder Post
decodeOnePost = at ["post"] decodePost


decodePost : Json.Decoder Post
decodePost = Json.object7 Post
    ("slug" := string)
    ("uuid" := string)
    ("title" := string)
    ("html" := string)
    ("markdown" := string)
    ("publishedAt" := oneOf
      [ null Nothing
      , Json.map parseDate string
      ]
    )
    (Json.map
      (parseDate >> (Maybe.withDefault (ISO.fromTime 0)))
      ("updatedAt" := string)
    )


nullOr : Decoder a -> Decoder (Maybe a)
nullOr decoder =
  oneOf
  [ null Nothing
  , Json.map Just decoder
  ]


parseDate : String -> Maybe(ISO.Time)
parseDate str = Result.toMaybe (ISO.fromString str)