```haskell
applySolution :: Reflex t
              => Behavior t Int
              -> Behavior t Int
              -> Behavior t Int
applySolution bIn1 bIn2 =
  pure 0
```
=====
Again, this is not what we want.
=====
```haskell
applySolution :: Reflex t
              => Behavior t Int
              -> Behavior t Int
              -> Behavior t Int
applySolution bIn1 bIn2 =
  _       bIn1     bIn2
```
=====
We're going to need both inputs ...
=====
```haskell
applySolution :: Reflex t
              => Behavior t Int
              -> Behavior t Int
              -> Behavior t Int
applySolution bIn1 bIn2 =
  _   <$> bIn1 <*> bIn2
```
=====
... and we're going to need to use the usual `Applicative` machinery ...
=====
```haskell
applySolution :: Reflex t
              => Behavior t Int
              -> Behavior t Int
              -> Behavior t Int
applySolution bIn1 bIn2 =
  (*) <$> bIn1 <*> bIn2
```
=====
... to lift the function we want over the `Behavior`s.
