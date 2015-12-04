module Empire.Utils.ParserMock where

import Prologue
import Text.Read (readMaybe)

asInteger :: String -> Maybe Int
asInteger expr = readMaybe expr

asString :: String -> Maybe String
asString expr = readMaybe expr
