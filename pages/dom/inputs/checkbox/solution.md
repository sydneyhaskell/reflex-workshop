```haskell
todoItem :: MonadWidget t m
         => TodoItem
         -> m (Event t (TodoItem -> TodoItem), Event t ())
todoItem item =
  divClass "d-flex flex-row align-items-center" $ do








     
     
     
     
     
      







    pure (_      , _      )
```
=====
We start with our layout magic from last time.
=====
```haskell
todoItem :: MonadWidget t m
         => TodoItem
         -> m (Event t (TodoItem -> TodoItem), Event t ())
todoItem item =
  divClass "d-flex flex-row align-items-center" $ do
    let
      iComplete = item ^. todoItem_complete
      iText     = item ^. todoItem_text





     
     
     
     
     
      







    pure (_      , _      )
```
=====
We break apart the initial values.
=====
```haskell
todoItem :: MonadWidget t m
         => TodoItem
         -> m (Event t (TodoItem -> TodoItem), Event t ())
todoItem item =
  divClass "d-flex flex-row align-items-center" $ do
    let
      iComplete = item ^. todoItem_complete
      iText     = item ^. todoItem_text

    eComplete <- divClass "p-1" $ do
      cb <- checkbox iComplete def
      pure $ const <$> cb ^. checkbox_change

     
     
     
     
     
      







    pure (_      , _      )
```
=====
We add a checkbox with the right initial value, and have it return an `Event t (Bool -> Bool)`.
=====
```haskell
todoItem :: MonadWidget t m
         => TodoItem
         -> m (Event t (TodoItem -> TodoItem), Event t ())
todoItem item =
  divClass "d-flex flex-row align-items-center" $ do
    let
      iComplete = item ^. todoItem_complete
      iText     = item ^. todoItem_text

    eComplete <- divClass "p-1" $ do
      cb <- checkbox iComplete def
      pure $ const <$> cb ^. checkbox_change

    dComplete <- foldDyn ($) iComplete eComplete

    let
      dCompleteClass = bool "" " completed" <$> dComplete
      
      







    pure (_      , _      )
```
=====
We build up a `Dynamic t Bool` of the completion status and use it build a `Dynamic` class name
=====
```haskell
todoItem :: MonadWidget t m
         => TodoItem
         -> m (Event t (TodoItem -> TodoItem), Event t ())
todoItem item =
  divClass "d-flex flex-row align-items-center" $ do
    let
      iComplete = item ^. todoItem_complete
      iText     = item ^. todoItem_text

    eComplete <- divClass "p-1" $ do
      cb <- checkbox iComplete def
      pure $ const <$> cb ^. checkbox_change

    dComplete <- foldDyn ($) iComplete eComplete

    let
      dCompleteClass = bool "" " completed" <$> dComplete
    elDynClass "div" (pure "p-1" <> dCompleteClass) $
      text iText







    pure (_      , _      )
```
=====
We display the text with the `Dynamic` class
=====
```haskell
todoItem :: MonadWidget t m
         => TodoItem
         -> m (Event t (TodoItem -> TodoItem), Event t ())
todoItem item =
  divClass "d-flex flex-row align-items-center" $ do
    let
      iComplete = item ^. todoItem_complete
      iText     = item ^. todoItem_text

    eComplete <- divClass "p-1" $ do
      cb <- checkbox iComplete def
      pure $ const <$> cb ^. checkbox_change

    dComplete <- foldDyn ($) iComplete eComplete

    let
      dCompleteClass = bool "" " completed" <$> dComplete
    elDynClass "div" (pure "p-1" <> dCompleteClass) $
      text iText

    eRemove <- divClass "p-1" $
      button "x"




    pure (_      , eRemove)
```
=====
We add the remove button in like before.
=====
```haskell
todoItem :: MonadWidget t m
         => TodoItem
         -> m (Event t (TodoItem -> TodoItem), Event t ())
todoItem item =
  divClass "d-flex flex-row align-items-center" $ do
    let
      iComplete = item ^. todoItem_complete
      iText     = item ^. todoItem_text

    eComplete <- divClass "p-1" $ do
      cb <- checkbox iComplete def
      pure $ const <$> cb ^. checkbox_change

    dComplete <- foldDyn ($) iComplete eComplete

    let
      dCompleteClass = bool "" " completed" <$> dComplete
    elDynClass "div" (pure "p-1" <> dCompleteClass) $
      text iText

    eRemove <- divClass "p-1" $
      button "x"

    let
      eChange = over todoItem_complete <$> eComplete

    pure (eChange, eRemove)
```
=====
We then create and return the `Event` that changes the `TodoItem`
=====
```haskell
todoComplete :: MonadWidget t m
             => Bool
             -> m (Event t (Bool -> Bool))
todoComplete iComplete =
  divClass "p-1" $ do
    cb <- checkbox iComplete def
    pure $ const <$> cb ^. checkbox_change

```

```haskell
todoText :: MonadWidget t m
         => Dynamic t Bool
         -> Text
         -> m ()
todoText dComplete iText = do
  let
    dCompleteClass = bool "" " completed" <$> dComplete
  elDynClass "div" (pure "p-1" <> dCompleteClass) $
    text iText
```

```haskell
todoRemove :: MonadWidget t m
           => m (Event t ())
todoRemove =
  divClass "p-1" $
     button "x"
```

```haskell
todoItem :: MonadWidget t m
         => TodoItem
         -> m (Event t (TodoItem -> TodoItem), Event t ())
todoItem item =
  divClass "d-flex flex-row align-items-center" $ do
    let
      iComplete = item ^. todoItem_complete
      iText     = item ^. todoItem_text

    eComplete <- todoComplete iComplete

    dComplete <- foldDyn ($) iComplete eComplete

    todoText dComplete iText
    eRemove <- todoRemove

    let
      eChange = set todoItem_complete <$> updated dComplete

    pure (eChange, eRemove)
```
=====
We can break this up into a number of sub-components.
=====
```haskell
todoItemSolution :: MonadWidget t m
                 => TodoItem
                 -> m ()
todoItemSolution item = do
  (eChange, eRemove) <- el "div" $
    todoItem item

  el "div" $ do
    dCountChange <- count eChange

    text "Change has been fired "
    display dCountChange
    text " time"
    dynText $ bool "s" "" . (== 1) <$> dCount

  el "div" $ do
    dCountRemove <- count eRemove

    text "Remove has been fired "
    display dCountRemove
    text " time"
    dynText $ bool "s" "" . (== 1) <$> dCount
```
=====
We update our test harness to report on this extra `Event` ...
=====
```haskell
firings :: MonadWidget t m
        => Text
        -> Event t a
        -> m ()
firings label e =
  el "div" $ do
    dCount <- count e

    text label
    text " has been fired "
    display dCount
    text " time"
    dynText $ bool "s" "" . (== 1) <$> dCount
```

```haskell
todoItemSolution :: MonadWidget t m
                 => TodoItem
                 -> m ()
todoItemSolution item = do
  (eChange, eRemove) <- el "div" $
    todoItem item

  firings "Change" eChange
  firings "Remove" eRemove
```
=====
... and we can factor out the duplication.
