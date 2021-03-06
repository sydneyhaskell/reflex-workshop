{-|
Copyright   : (c) 2018, Commonwealth Scientific and Industrial Research Organisation
License     : BSD3
Maintainer  : dave.laing.80@gmail.com
Stability   : experimental
Portability : non-portable
-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
module Todo.Solution.List.Part8 where

import Control.Lens

import qualified Data.Text as Text

import qualified Data.Map as Map

import Reflex.Dom.Core

import Todo.Common

import Todo.Solution.Item.Part5

addItem :: MonadWidget t m
        => m (Event t TodoItem)
addItem = mdo
  ti <- textInput $
    def & setValue .~ ("" <$ eEnter)

  let
    eEnter    = keypress Enter ti
    bText     = current $ value ti
    eStripped = Text.strip <$> bText <@ eEnter
    eText     = ffilter (not . Text.null) eStripped
    eAdd      = TodoItem False <$> eText

  pure eAdd

todoListSolution :: MonadWidget t m
                 => [TodoItem]
                 -> m ()
todoListSolution items = mdo
  eItem <- addItem
  eAdd  <- numberOccurrencesFrom (length items) eItem
  let
    eInsert = (\(k,v) -> k =: Just v) <$> eAdd
    m = Map.fromList . zip [0..] $ items
  dmes <- listHoldWithKey m eListChange $ \_ item -> do
    (_, eRemove) <- todoItem item
    pure eRemove

  let
    eRemoves =
      fmap (Nothing <$) .
      switchDyn .
      fmap mergeMap $
      dmes
    eListChange =
      leftmost [eRemoves, eInsert]

  pure ()
