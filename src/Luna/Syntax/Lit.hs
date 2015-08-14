module Luna.Syntax.Lit where

import           Flowbox.Prelude
import qualified Data.Text.AutoBuilder as Text



data Lit = Int Int
         | String Text.AutoBuilder
         deriving (Show)

instance IsString Lit where
    fromString = String . fromString