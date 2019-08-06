{-# LANGUAGE RecursiveDo #-}
module Main where

import           Prelude                    (error)
import           Common.Prelude
import           Common.ClientId            (clientId)
import           Common.Report              (fatal)
import           Control.Concurrent.Chan    (Chan)
import qualified Control.Concurrent.Chan    as Chan
import           Control.Concurrent.MVar
import qualified JS.Mount                   as Mount
import           JS.UUID                    (generateUUID)
import           NodeEditor.Event.Engine    (LoopRef (LoopRef))
import qualified NodeEditor.Event.Engine    as Engine
import qualified NodeEditor.React.Model.App as App
import qualified NodeEditor.React.Store     as Store
import qualified NodeEditor.React.View.App  as App
import           NodeEditor.State.Global    (mkState)
import qualified React.Flux                 as React
import           System.Random              (newStdGen)
import           WebSocket                  (WebSocket)
import           GHC.Stack                  (HasCallStack)



runApp :: Chan (IO ()) -> WebSocket -> IO ()
runApp chan socket = do
    random         <- newStdGen
    let openedFile = Nothing --Mount.openedFile
    mdo
        let loop = LoopRef chan state
        Engine.scheduleInit loop
        appRef <- Store.createApp (App.mk openedFile) $ Engine.scheduleEvent loop
        React.reactRender Mount.mountPoint (App.app appRef) ()
        let initState = mkState appRef clientId random
        state <- newMVar initState
        Engine.connectEventSources socket loop
    App.focus

withActiveConnection :: HasCallStack => (WebSocket -> IO ()) -> IO ()
withActiveConnection action = do
  action (error "SOCKET SOCKET SOCKET")

main :: IO ()
main = do
    chan <- Chan.newChan
    withActiveConnection $ runApp chan
    Engine.start chan
