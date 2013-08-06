---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2013
---------------------------------------------------------------------------

module Luna.Codegen.Hs.AST.DataType (
    DataType(..),
    empty,
    genCode,
    addDeriving,
    name
)where

import           Data.String.Utils                 (join)

import qualified Luna.Codegen.Hs.AST.Expr        as Expr
import           Luna.Codegen.Hs.AST.Expr          (Expr)
import qualified Luna.Codegen.Hs.AST.Deriving    as Deriving
import           Luna.Codegen.Hs.AST.Deriving      (Deriving)


data DataType = DataType { cls       :: Expr
                         , cons      :: [Expr]
                         , derivings :: [Deriving]
                         } deriving (Show)


empty :: DataType
empty = DataType Expr.empty [] []


genCode :: DataType -> String
genCode dt =  "data " ++ Expr.genCode (cls dt) ++ " = " 
           ++ join " | "  (map Expr.genCode (cons dt))
           ++ Deriving.genCode (derivings dt)


name :: DataType -> String
name dt = Expr.name $ cls dt


addDeriving :: Deriving -> DataType -> DataType
addDeriving d dt = dt { derivings = d : (derivings dt)}


