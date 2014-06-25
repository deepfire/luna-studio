---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE ViewPatterns  #-}

module Flowbox.Graphics.Composition.Generators.Filter where

import Flowbox.Prelude                                    as P hiding ((<*))
import Flowbox.Graphics.Composition.Generators.Structures
import Flowbox.Math.Matrix                                as M
import Flowbox.Graphics.Utils

import Data.Array.Accelerate     as A
import Math.Space.Space
import Math.Coordinate.UV        as UV
import Math.Coordinate.Cartesian as Cartesian

data Filter = Filter { window :: Exp Double
                     , apply :: Exp Double -> Exp Double
                     }

box :: Filter
box = Filter 0.5 $ \t -> A.cond (t >* -0.5 &&* t <=*  0.5) 1.0 0.0

-- TODO: Find the name
basic :: Filter
basic = Filter 1.0 $ \(abs -> t) -> A.cond (t <* 1.0) ((2.0 * t - 3.0) * t * t + 1.0) 0.0


triangle :: Filter
triangle = Filter 1.0 $ \(abs -> t) -> A.cond (t <* 1.0) (1.0 - t) 0.0

bell :: Filter
bell = Filter 1.5 $ \(abs -> t) -> A.cond (t <* 0.5) (0.75 - t * t) 
                                 $ A.cond (t <* 1.5) (0.5 * ((t - 1.5)*(t - 1.5)))
                                 $ 0.0

bspline :: Filter
bspline = Filter 2.0 $ \(abs -> t) -> A.cond (t <* 1.0) ((0.5 * t * t * t) - t * t + (2.0 / 3.0))
                                    $ A.cond (t <* 2.0) ((1.0 / 6.0) * ((2 - t) * (2 - t) * (2 - t)))
                                    $ 0.0

lanczos :: Exp Double -> Filter
lanczos a = Filter a $ \(abs -> t) -> A.cond (t <=*  1e-6) 1.0 
                                    $ A.cond (t <* a) ((a * sin (pi * t) * sin (pi * t / a)) / (pi * pi * t * t))
                                    $ 0.0

lanczos2 :: Filter
lanczos2 = lanczos 2

lanczos3 :: Filter
lanczos3 = lanczos 3

polynomial :: Exp Double -> Exp Double -> Filter
polynomial b c = Filter 2.0 $ \(abs -> t) -> (/6.0) $ A.cond (t <* 1.0) (((12.0 - 9.0 * b - 6.0 * c) * (t * t * t)) + ((-18.0 + 12.0 * b + 6.0 * c) * t * t) + (6.0 - 2 * b))
                                                    $ A.cond (t <* 2.0) (((-1.0 * b - 6.0 * c) * (t * t * t)) + ((6.0 * b + 30.0 * c) * t * t) + ((-12.0 * b - 48.0 * c) * t) + (8.0 * b + 24 * c))
                                                    $ 0.0

mitchell :: Filter
mitchell = polynomial (1.0 / 3.0) (1.0 / 3.0)

catmulRom :: Filter
catmulRom = polynomial 0.0 0.5

gauss :: Exp Double -> Filter
gauss sigma = Filter ((10.0 / 3.0) * sigma) $ \t -> exp (-(t ** 2) / (2 * sigma * sigma)) / (sigma * sqrt (2 * pi))

-- TODO: "kernelizing" function
