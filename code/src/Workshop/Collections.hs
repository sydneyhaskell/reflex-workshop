{-|
Copyright   : (c) 2018, Commonwealth Scientific and Industrial Research Organisation
License     : BSD3
Maintainer  : dave.laing.80@gmail.com
Stability   : experimental
Portability : non-portable
-}
{-# LANGUAGE OverloadedStrings #-}
module Workshop.Collections (
    collectionsSection
  ) where

import Reflex.Dom.Core

import Util.Section

import Workshop.Collections.Lists

collectionsSection :: MonadWidget t m => Section t m
collectionsSection =
  Section "Collections" [
    listsSubSection
  ]
