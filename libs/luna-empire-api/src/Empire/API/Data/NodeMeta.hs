module Empire.API.Data.NodeMeta where

import Prologue
import Data.Binary          (Binary)

data NodeMeta = NodeMeta { _position      :: (Double, Double)
                         , _displayResult :: Bool
                         } deriving (Generic, Show, Eq, Ord)

makeLenses ''NodeMeta

instance Default NodeMeta where
    def = NodeMeta def True

instance Binary NodeMeta
