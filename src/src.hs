module Src where

foreign export ccall hs_hello :: IO ()

hs_hello :: IO ()
hs_hello = putStrLn "Hello, world from Haskell !"
