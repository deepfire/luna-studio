---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2013
---------------------------------------------------------------------------

module Luna.Codegen.Hs.AST.Module (
    Module(..),
    empty,
    base,
    addExpr,
    addExprs,
    addAlias,
    addExt,
    genCode,
    mkInst,
    addDataType,
    addFunction,
    addInstance,
    addImport,
    addImports
)where

import           Data.Set                          (Set)
import qualified Data.Set                        as Set

import qualified Luna.Codegen.Hs.Path            as Path
import           Luna.Codegen.Hs.Path              (Path)
import qualified Luna.Codegen.Hs.Import          as Import
import           Luna.Codegen.Hs.Import            (Import)
import qualified Luna.Codegen.Hs.AST.Function    as Function
import           Luna.Codegen.Hs.AST.Function      (Function)
import qualified Luna.Codegen.Hs.AST.Instance    as Instance
import           Luna.Codegen.Hs.AST.Instance      (Instance)
import qualified Luna.Codegen.Hs.AST.DataType    as DataType
import           Luna.Codegen.Hs.AST.DataType      (DataType)
import qualified Luna.Codegen.Hs.AST.Expr        as Expr
import           Luna.Codegen.Hs.AST.Expr          (Expr)
import qualified Luna.Codegen.Hs.AST.Extension   as Extension
import           Luna.Codegen.Hs.AST.Extension     (Extension)
import           Data.String.Utils                 (join)

data Module = Module { path       :: Path
                     , submodules :: [Module]
                     , imports    :: Set Import
                     , datatypes  :: [DataType]
                     , functions  :: [Function]
                     , instances  :: [Instance]
                     , exprs      :: [Expr]
                     , extensions :: [Extension]
                     --, datatypes :: [DataType]
                     --, classes   

                        
                     } deriving (Show)

empty :: Module
empty = Module Path.empty [] Set.empty [] [] [] [] []

base :: Module
base = empty {imports = Set.singleton $ Import.simple (Path.fromList ["Flowbox'", "Core"])}

header :: String
header = "-- This is Flowbox generated file.\n\n"


genCode :: Module -> String
genCode m =  header
            ++ exts
            ++ "module "          ++ mypath ++ " where\n\n" 
            ++ "-- imports\n"     ++ imps   ++ "\n\n"
            ++ "-- datatypes\n"   ++ dtypes ++ "\n\n"
            ++ "-- functions\n"   ++ funcs  ++ "\n\n"
            ++ "-- instances\n"   ++ insts  ++ "\n\n"
            ++ "-- expressions\n" ++ exps  
    where
        exts   = Extension.genCode $ extensions m
        mypath = (Path.toString . Path.toModulePath . path) m
        imps   = join "\n" $ map Import.genCode   (Set.elems $ imports m)
        dtypes = join "\n" $ map DataType.genCode (datatypes m)
        funcs  = join "\n" $ map Function.genCode (functions m)
        insts  = join "\n" $ map Instance.genCode (instances m)
        exps   = join "\n" $ map Expr.genCode     (exprs m)



addExpr :: Expr -> Module -> Module
addExpr expr self = self { exprs = expr : exprs self }


addExprs :: [Expr] -> Module -> Module
addExprs exprs' self = foldr addExpr self exprs'


addAlias :: (String, String) -> Module -> Module
addAlias alias = addExpr (Expr.mkAlias alias)


addExt :: Extension -> Module -> Module
addExt ext self = self {extensions = ext : extensions self}


mkInst :: (String, String, String, String) -> Module -> Module
mkInst (nameC, nameT, nameMT, name) = addExpr $ Expr.Call "mkInst''" (Expr.THTypeCtx nameC : map Expr.THExprCtx [nameT, nameMT, name]) Expr.Pure


addDataType :: DataType -> Module -> Module
addDataType dt self = self {datatypes = dt : datatypes self}


addFunction :: Function -> Module -> Module
addFunction func self = self {functions = func : functions self}


addInstance :: Instance -> Module -> Module
addInstance inst self = self {instances = inst : instances self}


addImport :: Import -> Module -> Module
addImport imp self = self {imports = Set.insert imp $ imports self}


addImports :: [Import] -> Module -> Module
addImports imps self = foldr addImport self imps