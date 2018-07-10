{-# LANGUAGE CPP              #-}
{-# LANGUAGE TypeApplications #-}

module LunaStudio.Data.NodeMeta where

import           Data.Aeson.Types           (FromJSON, ToJSON)
import           Data.Binary                (Binary)

#ifndef __GHCJS__
import qualified Data.Vector.Storable.Foreign as Foreign
import           Foreign.Storable.Utils     (sizeOf')
#endif
import           Foreign.Ptr                (castPtr, plusPtr)
import           Foreign.Storable           (Storable(..))
import qualified Foreign.Storable           as Storable
import           Foreign.Storable.Tuple     ()
import           LunaStudio.Data.Position   (Position)
import           LunaStudio.Data.Visualizer (VisualizerName, VisualizerPath)
import           Prologue
import           System.IO.Unsafe           (unsafePerformIO)

data NodeMetaTemplate t = NodeMeta { _position           :: Position
                                   , _displayResult      :: Bool
                                   , _selectedVisualizer :: Maybe (t, t)
                                   } deriving (Eq, Generic, Show)

makeLenses ''NodeMetaTemplate

instance Eq a => Ord (NodeMetaTemplate a) where
    compare a b = compare (a ^. position) (b ^. position)

type NodeMeta = NodeMetaTemplate Text

#ifndef __GHCJS__
type VName = Foreign.Vector Char
type VPath = Foreign.Vector Char
type NodeMetaS = NodeMetaTemplate (Foreign.Vector Char)
#endif

instance Default (NodeMetaTemplate t) where
    def = NodeMeta def False def

instance Binary   NodeMeta
instance NFData   NodeMeta
instance FromJSON NodeMeta
instance ToJSON   NodeMeta

#ifndef __GHCJS__
wordSize :: Int
wordSize = Storable.sizeOf @Int undefined

instance Storable NodeMetaS where
    sizeOf _  = sizeOf (undefined :: Position)
              + sizeOf (undefined :: Bool)
              + sizeOf (undefined :: Maybe (VName, VPath))
    alignment _ = 8
    peek ptr  = NodeMeta <$> (peek (castPtr ptr))
                         <*> (peek (ptr `plusPtr` sizeOf (undefined :: Position)))
                         <*> (peek (ptr `plusPtr` (sizeOf (undefined :: Position) + sizeOf (undefined :: Bool))))
    poke p nm = do
        poke (castPtr p) (nm ^. position)
        poke (p `plusPtr` sizeOf (undefined::Position)) (nm ^. displayResult)
        poke (p `plusPtr` (sizeOf (undefined::Position) + sizeOf (undefined::Bool))) (nm ^. selectedVisualizer)

toNodeMeta :: NodeMetaS -> NodeMeta
toNodeMeta (NodeMeta p d s) = NodeMeta p d (over both (convert . unsafePerformIO . Foreign.toList) <$> s)

toNodeMetaS :: NodeMeta -> NodeMetaS
toNodeMetaS (NodeMeta p d s) = NodeMeta p d (over both (unsafePerformIO . Foreign.fromList . convert) <$> s)

#endif