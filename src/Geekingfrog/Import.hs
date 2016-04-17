{-# LANGUAGE OverloadedStrings #-}

module Geekingfrog.Import where

import Database.Persist
import Database.Persist.Sqlite

import Control.Monad.IO.Class (liftIO, MonadIO)
import Data.DateTime (fromSeconds)
import Data.Time.Clock (getCurrentTime)
import Control.Applicative (liftA)
import Control.Monad (zipWithM_)
import Control.Monad.Logger --(runStderrLoggingT)

import qualified Geekingfrog.Db.Types as DT
import qualified Geekingfrog.Db.PostStatus as DT
import Geekingfrog.Types

import Control.Monad.Trans.Reader (ReaderT)

testPersistent :: IO ()
testPersistent = runSqlite ":memory:" $ do
-- testPersistent = runSqlite "testing.sqlite" $ do
  runMigration DT.migrateAll
  -- now <- liftIO getCurrentTime
  -- let tagId = TagKey 1
  -- let tag = Tag "testUUID" "testName" "test-slug" (Just "test description") False now 1 now 1
  -- insertKey tagId tag
  -- testtag <- getBy $ UniqueSlug "test-slug"
  -- liftIO $ putStrLn $ "printing tag: " ++ show testtag
  -- let foo = liftA (tagName . entityVal) testtag
  -- liftIO $ putStrLn "---"
  liftIO $ putStrLn "all is well"

importData :: [Tag] -> [Post] -> [PostTag] -> IO ()
importData tags posts postTags = runNoLoggingT $  -- runStderrLoggingT
  withSqlitePool ":memory:" 10 $ \pool -> liftIO $
    flip runSqlPersistMPool pool $ do
      runMigration DT.migrateAll
      importTags [head tags]
      -- importPosts posts
      -- importPostTags postTags
      liftIO . putStrLn $ "All imported"

importTags :: (MonadIO m) => [Tag] -> ReaderT SqlBackend m ()
importTags tags = do
  let tagIds = fmap (DT.TagKey . tagId) tags
  let dbTags = fmap tagToDb tags
  zipWithM_ insertKey tagIds dbTags
  liftIO . putStrLn $ "Successfully imported " ++ show (length tags) ++ " tags"

importPosts :: (MonadIO m) => [Post] -> ReaderT SqlBackend m ()
importPosts posts = do
  let postIds = fmap (DT.PostKey . postId) posts
  let dbPosts = fmap postToDb posts
  zipWithM_ insertKey postIds dbPosts
  liftIO . putStrLn $ "Successfully imported " ++ show (length posts) ++ " posts"

importPostTags :: (MonadIO m) => [PostTag] -> ReaderT SqlBackend m ()
importPostTags postTags = do
  let ids = fmap (DT.PostTagKey . postTagId) postTags
  let dbPostTags = fmap postTagToDb postTags
  zipWithM_ insertKey ids dbPostTags
  liftIO . putStrLn $ "Successfully imported " ++ show (length postTags) ++ " post-tags relations"

tagToDb :: Tag -> DT.Tag
tagToDb tag = DT.Tag (tagUuid tag)
                     (tagName tag)
                     (tagSlug tag)
                     (tagDescription tag)
                     (tagHidden tag)
                     (tagCreatedAt tag)

postStatusToDb :: PostStatus -> DT.PostStatus
postStatusToDb Published = DT.Published
postStatusToDb Draft     = DT.Draft

postToDb :: Post -> DT.Post
postToDb post = DT.Post (postStatusToDb $ postStatus post)
                        (postUuid post)
                        (postSlug post)
                        (postMarkdown post)
                        (postHtml post)
                        (postCreatedAt post)
                        (postUpdatedAt post)
                        (postLanguage post)
                        (postIsFeatured post)

postTagToDb :: PostTag -> DT.PostTag
postTagToDb pt = DT.PostTag (postTagTagId pt)
                            (postTagPostId pt)
                            (postTagSortOrder pt)
