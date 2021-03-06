```haskell
ffilterSolution :: Reflex t 
                => Event t Int 
                -> Event t Int
ffilterSolution eIn =
  never
```
=====
Again, the `never` `Event` isn't what we want...
=====
```haskell
ffilterSolution :: Reflex t 
                => Event t Int 
                -> Event t Int
ffilterSolution eIn =
                               eIn
```
=====
... and we're going to do something based on the input `Event`.
=====
```haskell
ffilterSolution :: Reflex t 
                => Event t Int 
                -> Event t Int
ffilterSolution eIn =
  ffilter (_                 ) eIn
```
=====
We're going to use `ffilter`, and we just need to come up with the predicate.
=====
```haskell
ffilterSolution :: Reflex t 
                => Event t Int 
                -> Event t Int
ffilterSolution eIn =
  ffilter (         (`mod` 3)) eIn
```
=====
For the predicate we take the value contained within the `Event`, calculate `mod 3` of that value ...
=====
```haskell
ffilterSolution :: Reflex t 
                => Event t Int 
                -> Event t Int
ffilterSolution eIn =
  ffilter ((== 0) . (`mod` 3)) eIn
```
=====
... and then check when that is equal to `0`.
