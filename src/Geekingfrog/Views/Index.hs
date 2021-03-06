{-# LANGUAGE OverloadedStrings #-}

module Geekingfrog.Views.Index where

import Text.Blaze.Html5 as H
import Text.Blaze.Html5.Attributes as A

import qualified Geekingfrog.Types as Types

import Geekingfrog.Views.Partials (
    postOverview
  , pageHead
  , navHeader
  , NavItem(..)
  , pageFooter
  )

newtype Index = Index [Types.Post]

instance H.ToMarkup Index where
    toMarkup (Index posts) = docTypeHtml $ do

      H.head $ pageHead (Just "Geek stuff by a batrachian")

      body ! class_ "home" $ do
          navHeader (Just Home)
          section ! class_ "hero" $
              H.div ! class_ "container hero-container" $ h1 ! class_ "main-title main-title__huge" $ "The Geekingfrog"

          section ! class_ "container content" $ do
              H.div ! class_ "posts" $ do
                  h2 "Blog"
                  p "Some brain dumps about various things, mostly coding, programming languages and open source projects. Here are the most recent posts."
                  ul ! class_ "posts-overview posts-overview__index" $
                      mapM_ ((li ! class_ "posts-overview--item") . postOverview) (take 5 posts)
              H.div ! class_ "misc" $ do
                  h2 "About me"
                  p "I'm Greg, polyglot backend developer."
                  ul ! class_ "misc-list" $ do
                      li ! class_ "misc-item" $ b "I'm from" >> H.span " France"
                      li ! class_ "misc-item" $ b "I currently work " >> H.span " in the UK"
                      p "I've built various applications for different business and scales \
                      \ (from a few views per days to millions of requests per hour)."
                      p "I've also managed and automated the deployement and monitoring of these service on AWS."
                      p "On the front end, I've translated designer vision into beautiful websites, as \
                      \ well as complex single page application in ember and react."
                      p "I'm interested in Functional programming (haskell and clojure) and distributed systems."

          pageFooter
