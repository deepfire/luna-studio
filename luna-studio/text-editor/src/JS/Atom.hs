
{-# LANGUAGE JavaScriptFFI #-}

module JS.Atom
    ( activeLocation
    , insertCode
    , pushStatus
    , setBuffer
    , setClipboard
    , subscribeDiff
    , subscribeEventListenerInternal
    ) where

import           Common.Data.JSON              (fromJSONVal)
import           Common.Prelude
import           Control.Monad.Trans.Maybe     (MaybeT (MaybeT), runMaybeT)
import qualified Data.Text                     as Text
import           GHCJS.Foreign.Callback
import           GHCJS.Marshal.Pure            (PFromJSVal (pFromJSVal), PToJSVal (pToJSVal))
import           LunaStudio.Data.GraphLocation (GraphLocation)
import           LunaStudio.Data.Point         (Point (Point))
import qualified LunaStudio.Data.Point         as Point
import           TextEditor.Event.Internal     (InternalEvent, InternalEvent (..))
import           TextEditor.Event.Text         (TextEvent (TextEvent))
import qualified TextEditor.Event.Text         as TextEvent


foreign import javascript safe "atomCallbackTextEditor.insertCode($1, $2, $3, $4)"
    insertCode' :: JSString -> JSVal -> JSVal -> JSString -> IO ()

foreign import javascript safe "atomCallbackTextEditor.setBuffer($1, $2)"
    setBuffer :: JSString -> JSString -> IO ()

foreign import javascript safe "atomCallbackTextEditor.setClipboard($1, $2)"
    setClipboard :: JSString -> JSString -> IO ()

foreign import javascript safe "atomCallbackTextEditor.pushStatus($1, $2, $3)"
    pushStatus :: JSString -> JSString -> JSString -> IO ()

foreign import javascript safe "atomCallbackTextEditor.subscribeEventListenerInternal($1)"
    subscribeEventListenerInternal' :: Callback (JSVal -> IO ()) -> IO ()

foreign import javascript safe "($1).unsubscribeEventListenerInternal()"
    unsubscribeEventListenerInternal' :: Callback (JSVal -> IO ()) -> IO ()

foreign import javascript safe "atomCallbackTextEditor.subscribeDiff($1)"
    subscribeDiff' :: Callback (JSVal -> IO ()) -> IO ()

foreign import javascript safe "($1).unsubscribeDiff()"
    unsubscribeDiff' :: Callback (JSVal -> IO ()) -> IO ()

foreign import javascript safe "$1.uri"    getPath   :: JSVal -> JSVal
foreign import javascript safe "$1.start"  getStart  :: JSVal -> JSVal
foreign import javascript safe "$1.end"    getEnd    :: JSVal -> JSVal
foreign import javascript safe "$1.text"   getText   :: JSVal -> JSVal
foreign import javascript safe "$1.cursor" getCursor :: JSVal -> JSVal
foreign import javascript safe "$1.column" getColumn :: JSVal -> Int
foreign import javascript safe "$1.row"    getRow    :: JSVal -> Int
foreign import javascript safe "{column: $1, row: $2}" mkPoint   :: Int -> Int -> JSVal
foreign import javascript safe "globalRegistry.activeLocation" activeLocation' :: IO JSVal

instance PFromJSVal Point where
    pFromJSVal jsval = Point (getColumn jsval) (getRow jsval)

instance PToJSVal Point where
    pToJSVal point = mkPoint (point ^. Point.column) (point ^. Point.row)

instance FromJSVal GraphLocation where fromJSVal = fromJSONVal
instance FromJSVal InternalEvent where fromJSVal = fromJSONVal

instance FromJSVal TextEvent where
    fromJSVal jsval = runMaybeT $ do
        location <- MaybeT $ fromJSVal $ getPath jsval
        let start    = pFromJSVal $ getStart jsval
            end      = pFromJSVal $ getEnd jsval
            text     = pFromJSVal $ getText jsval
            cursor   = pFromJSVal $ getCursor jsval
            result   = TextEvent location start end text $ Just cursor
        return result

activeLocation :: MonadIO m => m (Maybe GraphLocation)
activeLocation = liftIO $ fromJSVal =<< activeLocation'

subscribeDiff :: (TextEvent -> IO ()) -> IO (IO ())
subscribeDiff callback = do
    wrappedCallback <- syncCallback1 ContinueAsync $ \js -> withJustM_ (fromJSVal js) callback
    subscribeDiff' wrappedCallback
    return $ unsubscribeDiff' wrappedCallback >> releaseCallback wrappedCallback

insertCode :: TextEvent -> IO ()
insertCode = do
    uri   <- view TextEvent.filePath
    start <- pToJSVal . view TextEvent.start
    end   <- pToJSVal . view TextEvent.end
    text  <- view TextEvent.text
    return $ insertCode' (convert uri) start end $ convert $ Text.unpack text

subscribeEventListenerInternal :: (InternalEvent -> IO ()) -> IO (IO ())
subscribeEventListenerInternal callback = do
    wrappedCallback <- syncCallback1 ContinueAsync $ \jsval -> withJustM (fromJSVal jsval) callback
    subscribeEventListenerInternal' wrappedCallback
    return $ unsubscribeEventListenerInternal' wrappedCallback >> releaseCallback wrappedCallback
