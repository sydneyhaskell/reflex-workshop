{-|
Copyright   : (c) 2018, Commonwealth Scientific and Industrial Research Organisation
License     : BSD3
Maintainer  : dave.laing.80@gmail.com
Stability   : experimental
Portability : non-portable
-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
module Util.Exercises (
    Problem(..)
  , runProblems
  ) where

import Data.Bool (bool)
import Data.Maybe (isJust, fromMaybe)
import Data.Monoid ((<>))
import Data.List (transpose)

import Control.Lens

import qualified Data.IntMap as IntMap

import Reflex.Dom.Core

import Util.Bootstrap
import Util.File
import Util.WorkshopState

data Problem t m =
  Problem {
    esGoal :: m ()
  , esExercise :: m ()
  , esSolution :: FilePath
  }

runProblems :: MonadWidget t m
            => FilePath
            -> [m (Problem t m)]
            -> Dynamic t ExerciseState
            -> m (Event t ExerciseState)
runProblems fp ps des = do
  mds <- fmap (fmap (\x -> x >> pure never)) . loadMarkdownSingle $ fp
  let problems = zipWith (runProblem des) [0..] ps
  es <- sequence . mconcat . transpose $ [mds, problems]
  pure $ leftmost es

runProblem :: MonadWidget t m
           => Dynamic t ExerciseState
           -> Int
           -> m (Problem t m)
           -> m (Event t ExerciseState)
runProblem des i p = do
  Problem goal ex solFp <- p
  let
    dis = fromMaybe Goal . IntMap.lookup i . getExerciseState <$> des
    mkChange es v = ExerciseState . IntMap.insert i v . getExerciseState $ es
  e <- problem dis goal ex (solution solFp)
  pure $ mkChange <$> current des <@> e

problem :: MonadWidget t m
                 => Dynamic t Selected
                 -> m ()
                 -> m ()
                 -> (Int -> m (Event t Int))
                 -> m (Event t Selected)
problem dis goal ex sol = card $ mdo
  eWhich <- elClass "ul" "nav nav-pills nav-fill" $ do

    let
      tab label value check = elClass "li" "nav-item" $ do
        let
          dActive = bool "" "active" . check <$> dWhich
          dClass = pure "nav-link " <> dActive
          dAttr = ("class" =:) <$> dClass
        (e, _) <- elDynAttr' "a" dAttr $ text label
        pure $ value <$ domEvent Click e

    eProblem <- tab "Problem" Goal (has _Goal)
    eProgress <- tab "Progress" Exercise (has _Exercise)
    eSolution <- tab "Solution" (Solution 0) (has _Solution)
    eDone <- tab "Done" Done (has _Done)

    pure $ leftmost [eProblem, eProgress, eSolution, eDone]

  is <- sample . current $ dis
  dWhich <- holdDyn is eWhich

  let f Goal =
        goal >> pure never
      f Exercise =
        ex >> pure never
      f (Solution n) =
        fmap (fmap Solution) $ sol n
      f Done =
        pure never

  deSolIx <- widgetHold (f is) $ f <$> updated dWhich
  let eSolIx = switchDyn deSolIx

  pure . leftmost $ [eWhich, eSolIx]

solution :: MonadWidget t m
         => FilePath
         -> Int
         -> m (Event t Int)
solution fp n = mdo
  (codes, explanations) <- loadMarkdownAlternating fp

  let
    both = zip codes explanations
    renderIx i = render $ both !! i
    render (c, e) = do
      _ <- card c
      e

  dIndex <- divClass "d-flex flex-row justify-content-between p-1" $ do
    let
      isFirst = (== 0)
      isLast = (== (length both - 1))
      dDisable p = bool mempty ("disabled" =: "") . p <$> dIndex
      dDisablePrev = dDisable isFirst
      dDisableNext = dDisable isLast
      bClass = "class" =: "btn btn-primary"
    ePrev <- buttonDynAttr "Prev" (pure bClass <> dDisablePrev)
    eNext <- buttonDynAttr "Next" (pure bClass <> dDisableNext)
    let
      ePrevChecked = gate (not . isFirst <$> current dIndex) ePrev
      eNextChecked = gate (not . isLast  <$> current dIndex) eNext

    dIx <- foldDyn ($) n .
           mergeWith (.) $ [
               pred <$ ePrevChecked
             , succ <$ eNextChecked
             ]

    pure dIx

  _ <- widgetHold (renderIx n) $ renderIx <$> updated dIndex

  pure $ updated dIndex
