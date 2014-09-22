---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------
{-# LANGUAGE TemplateHaskell #-}

module Flowbox.Batch.FileSystem.Item where

import Flowbox.Prelude
import Flowbox.System.UniPath (UniPath)



data Item = File      { _path :: UniPath, _size :: Int }
          | Directory { _path :: UniPath, _size :: Int }
          | Other     { _path :: UniPath, _size :: Int }
          deriving (Show)

makeLenses ''Item
