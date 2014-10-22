---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------
{-# LANGUAGE TemplateHaskell #-}

module Luna.Interpreter.Session.Env.Env where

import qualified Flowbox.Batch.Project.Project               as Project
import           Flowbox.Data.MapForest                      (MapForest)
import           Flowbox.Data.Mode                           (Mode)
import           Flowbox.Data.SetForest                      (SetForest)
import           Flowbox.Prelude
import           Generated.Proto.Data.Value                  (Value)
import           Luna.Interpreter.Session.Cache.Info         (CacheInfo)
import           Luna.Interpreter.Session.Data.CallPoint     (CallPoint)
import           Luna.Interpreter.Session.Data.CallPointPath (CallPointPath)
import           Luna.Interpreter.Session.Data.DefPoint      (DefPoint)
import           Luna.Interpreter.Session.TargetHS.Reload    (ReloadMap)
import           Luna.Lib.Manager                            (LibManager)



data Env = Env { _cached            :: MapForest CallPoint CacheInfo
               , _watchPoints       :: SetForest CallPoint
               , _reloadMap         :: ReloadMap
               , _serializationMode :: Mode
               , _allReady          :: Bool

               , _libManager        :: LibManager
               , _projectID         :: Maybe Project.ID
               , _mainPtr           :: Maybe DefPoint
               , _resultCallBack    :: Project.ID -> CallPointPath -> Maybe Value -> IO ()
               }


makeLenses ''Env


mk :: LibManager -> Maybe Project.ID -> Maybe DefPoint
   -> (Project.ID -> CallPointPath -> Maybe Value -> IO ()) -> Env
mk = Env def def def def False


instance Default Env where
    def = mk def def def (const (const (void . return)))
