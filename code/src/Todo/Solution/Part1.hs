{-|
Copyright   : (c) 2018, Commonwealth Scientific and Industrial Research Organisation
License     : BSD3
Maintainer  : dave.laing.80@gmail.com
Stability   : experimental
Portability : non-portable
-}
{-# LANGUAGE OverloadedStrings #-}
module Todo.Solution.Part1 where

import Control.Monad
import Data.Bool

import Control.Lens

import Data.Text (Text)
import qualified Data.Text as Text

import Data.Map (Map)
import qualified Data.Map as Map

import Reflex.Dom.Core

import Todo.Common

todoItem :: MonadWidget t m
         => TodoItem
         -> m (Event t ())
todoItem ti = divClass "d-flex flex-row align-items-center" $ do
  divClass "p-1" $
    text $
      view todoItem_text ti
      -- ti ^. todoItem_text
  divClass "p-1" $
    button "x"

todoItemSolution :: MonadWidget t m
                 => TodoItem -> m ()
todoItemSolution ti = do
  eRemove <- el "div" $
    todoItem ti

  dCount <- count eRemove

  el "div" $ do
    text "Remove has been pressed "
    display dCount
    text " time"
    dynText $ bool "s" "" . (== 1) <$> dCount
  pure ()
