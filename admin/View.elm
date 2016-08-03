module View exposing (..)

import String as String
import Dict exposing (Dict)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes as A
import ISO8601 as ISO
import Markdown as Markdown

import Types as Types

view model =
  div [A.class "admin-container"] [
      controls
    , content model
  ]


controls : Html Types.Msg
controls = div [A.class "admin-controls"] [
    text "controls coming"
  ]


content : Types.Model -> Html Types.Msg
content model =
  case model.activeView of
    Types.Index ->
      div [A.class "admin-content"] [
        renderPostsList model.posts model.selectedPost
      , renderPostPreview model.selectedPost
      ]
    Types.Edit ->
      case model.selectedPost of
        Nothing -> text "something went wrong, no selected post in edit?"
        Just p ->
          div [] [
            button [onClick (Types.SelectPost p)] [text "back"]
          , renderEditPost p
          ]


renderPostsList : Maybe(Dict String Types.Post) -> Maybe Types.Post -> Html Types.Msg
renderPostsList model selectedPost =
  case model of
    Nothing -> text "No posts fetched yet"
    Just posts ->
      let
        sortedPosts = List.sortWith sortPublishedAt (Dict.values posts)
      in
        Html.ul
          [A.class "posts-list"]
          (List.map (renderPostHeader selectedPost) sortedPosts)

renderPostHeader : Maybe Types.Post -> Types.Post -> Html Types.Msg
renderPostHeader selectedPost post =
  let
    isSelected =
      case selectedPost of
        Nothing -> False
        Just p -> post == p
  in
  Html.li
    [
      onClick (Types.SelectPost post),
      A.classList [("posts-list-item", True), ("posts-list-item__selected", isSelected)]
    ]
    [ div
        [ A.class "posts-list-item--title" ]
        [text post.title]
    , div
        [
            A.classList [
              ("posts-list-item--date", True)
            , ("posts-list-item--date__draft", isNothing post.publishedAt)
            ]
        ]
        [text (Maybe.withDefault "(draft)" (lift prettyDate post.publishedAt))]
    ]

prettyDate : ISO.Time -> String
prettyDate time = String.join "-" (List.map toString [time.year, time.month, time.day])

renderPost : Types.Post -> Html Types.Msg
renderPost post = Html.li [] [text (toString post.publishedAt)]


renderPostPreview : Maybe(Types.Post) -> Html Types.Msg
renderPostPreview maybePost =
  let
    content = case maybePost of
      Nothing -> [text "No post selected"]
      Just p ->
        [ div [ A.class "post-preview" ]
          [ button [onClick (Types.EditPost p)] [text "Edit"]
          , Markdown.toHtml [A.class "blog-content"] p.markdown
          ]
        ]
  in
    div [A.class "post-preview-container"] content

-- DRAFT firsts, then most recent to most ancient post
sortPublishedAt : Types.Post -> Types.Post -> Order
sortPublishedAt a b = case (a.publishedAt, b.publishedAt) of
  (Nothing, Nothing) -> compare (ISO.toTime b.updatedAt) (ISO.toTime a.updatedAt)
  (Nothing, _) -> LT
  (_, Nothing) -> GT
  (Just ja, Just jb) -> compare (ISO.toTime jb) (ISO.toTime ja)


lift : (a -> b) -> Maybe a -> Maybe b
lift func thing = case thing of
  Nothing -> Nothing
  Just a -> Just (func a)

isNothing : Maybe a -> Bool
isNothing a = case a of
  Nothing -> True
  _ -> False


renderEditPost : Types.Post -> Html Types.Msg
renderEditPost p =
  div [] [
    text ("editting post" ++ p.title)
  , div [A.class "edit-post-container"] [
      textarea [A.class "edit-post--markdown"] [text p.markdown]
    , div [A.class "edit-post--html"] [div [A.id "render-anchor"] [text "foo"]]
    ]
  ]