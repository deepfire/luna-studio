---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

module Main where

import Data.EitherR (fmapL)

import           Flowbox.Control.Error               (eitherStringToM)
import qualified Flowbox.Interpreter.Error           as Error
import qualified Flowbox.Interpreter.Mockup.Graph    as Graph
import qualified Flowbox.Interpreter.Session.Cache   as Cache
import qualified Flowbox.Interpreter.Session.Session as Session
import           Flowbox.Prelude
import           Flowbox.System.Log.Logger


rootLogger :: Logger
rootLogger = getLogger "Flowbox"


logger :: LoggerIO
logger = getLoggerIO "Flowbox.Interpreter.Test"


main :: IO ()
main = do
    rootLogger setIntLevel 5
    let graph = Graph.mkGraph
                    [ (0, "(15 :: Int)")
                    , (1, "(12 :: Int)")
                    , (2, "(94 :: Int)")
                    , (3, "((+) :: Int -> Int -> Int)")
                    , (4, "((*) :: Int -> Int -> Int)")
                    ]
                    [ (0, 3, Graph.Dependency)
                    , (1, 3, Graph.Dependency)
                    , (2, 4, Graph.Dependency)
                    , (3, 4, Graph.Dependency)
                    ]
    result <- Session.run $ do
        Cache.runNode 0 graph
        Cache.runNode 1 graph
        Cache.runNode 2 graph
        Cache.runNode 3 graph
        Cache.runNode 4 graph
        Cache.dump 3
        Cache.dump 4
        Cache.invalidate 3
        Cache.dump 3
    eitherStringToM $ fmapL Error.format result
