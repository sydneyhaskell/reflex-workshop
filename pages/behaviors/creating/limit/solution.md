```haskell
limitSolution :: (Reflex t, MonadFix m, MonadHold t m)
              => Behavior t Int
              -> Event t ()
              -> Event t ()
              -> m (Behavior t Int)
limitSolution bCount eAdd eReset = mdo









 
 
  
  

  pure _
```
=====
Don't let the masses of blank lines scare you. 
=====
```haskell
limitSolution :: (Reflex t, MonadFix m, MonadHold t m)
              => Behavior t Int
              -> Event t ()
              -> Event t ()
              -> m (Behavior t Int)
limitSolution bCount eAdd eReset = mdo
  let
    defaultLimit = 5







 
 
  
  

  pure _
```
=====
We set up the default limit that we want. 
=====
```haskell
limitSolution :: (Reflex t, MonadFix m, MonadHold t m)
              => Behavior t Int
              -> Event t ()
              -> Event t ()
              -> m (Behavior t Int)
limitSolution bCount eAdd eReset = mdo
  let
    defaultLimit = 5







  bLimit <- _
  
  
  

  pure bLimit
```
=====
We put some pieces in place for our use of `RecursiveDo`.
=====
```haskell
limitSolution :: (Reflex t, MonadFix m, MonadHold t m)
              => Behavior t Int
              -> Event t ()
              -> Event t ()
              -> m (Behavior t Int)
limitSolution bCount eAdd eReset = mdo
  let
    defaultLimit = 5

    bLimitIncrease = (==) <$> bCount <*> bLimit
    eLimitIncrease = gate bLimitIncrease eReset




  bLimit <- _
  
  
  

  pure bLimit
```
=====
We allow for a limit increase if the user presses the "Reset" button while the counter is at the limit.
=====
```haskell
limitSolution :: (Reflex t, MonadFix m, MonadHold t m)
              => Behavior t Int
              -> Event t ()
              -> Event t ()
              -> m (Behavior t Int)
limitSolution bCount eAdd eReset = mdo
  let
    defaultLimit = 5

    bLimitIncrease = (==) <$> bCount <*> bLimit
    eLimitIncrease = gate bLimitIncrease eReset

    bLimitReset = (== 0) <$> bCount
    eLimitReset = gate bLimitReset eReset

  bLimit <- _
  
  
  

  pure bLimit
```
=====
We allow for the limit to be reset if the user presses "Reset" while the counter is at `0`.
=====
```haskell
limitSolution :: (Reflex t, MonadFix m, MonadHold t m)
              => Behavior t Int
              -> Event t ()
              -> Event t ()
              -> m (Behavior t Int)
limitSolution bCount eAdd eReset = mdo
  let
    defaultLimit = 5

    bLimitIncrease = (==) <$> bCount <*> bLimit
    eLimitIncrease = gate bLimitIncrease eReset

    bLimitReset = (== 0) <$> bCount
    eLimitReset = gate bLimitReset eReset

  bLimit <- hold defaultLimit . leftmost $ [
      (+1) <$> bLimit <@ eLimitIncrease
    , defaultLimit    <$ eLimitReset
    ]

  pure bLimit
```
=====
We then use these two `Event`s to adjust the limit.
