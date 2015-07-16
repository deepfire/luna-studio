module Reactive.Plugins.Core.Action.State.Global where


import           Data.Monoid
import           Data.Default
import           Control.Lens

import qualified JS.Camera
import           Object.Object
import           Object.Port
import qualified Object.Node    as Node     ( position )
import           Object.Node    hiding      ( position )
import           Utils.Vector
import           Utils.PrettyPrinter

import qualified Reactive.Plugins.Core.Action.State.Camera            as Camera
import qualified Reactive.Plugins.Core.Action.State.AddRemove         as AddRemove
import qualified Reactive.Plugins.Core.Action.State.Selection         as Selection
import qualified Reactive.Plugins.Core.Action.State.MultiSelection    as MultiSelection
import qualified Reactive.Plugins.Core.Action.State.Drag              as Drag
import qualified Reactive.Plugins.Core.Action.State.Connect           as Connect
import qualified Reactive.Plugins.Core.Action.State.NodeSearcher      as NodeSearcher


data State = State { _iteration      :: Integer
                   , _mousePos       :: Vector2 Int
                   , _screenSize     :: Vector2 Int
                   , _nodes          :: NodeCollection
                   , _camera         :: Camera.State
                   , _addRemove      :: AddRemove.State
                   , _selection      :: Selection.State
                   , _multiSelection :: MultiSelection.State
                   , _drag           :: Drag.State
                   , _connect        :: Connect.State
                   , _nodeSearcher   :: NodeSearcher.State
                   } deriving (Eq, Show)

makeLenses ''State

instance Default State where
    def = State def (Vector2 400 200) def def def def def def def def def

instance PrettyPrinter State where
    display (State iteration mousePos screenSize nodes camera addRemove selection multiSelection drag connect nodeSearcher)
        = "gS(" <> display iteration
         <> " " <> display mousePos
         <> " " <> display screenSize
         <> " " <> display nodes
         <> " " <> display camera
         <> " " <> display addRemove
         <> " " <> display selection
         <> " " <> display multiSelection
         <> " " <> display drag
         <> " " <> display connect
         <> " " <> display nodeSearcher
         <> ")"

instance Monoid State where
    mempty = def
    a `mappend` b = if a ^. iteration > b ^.iteration then a else b


toCamera :: State -> JS.Camera.Camera
toCamera state = JS.Camera.Camera (state ^. screenSize) (camState ^. Camera.pan) (camState ^. Camera.factor) where
    camState   = state ^. camera . Camera.camera
