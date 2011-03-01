module Data.LLVM.Private.PlaceholderTypeExtractors ( getInt
                                                   , getBool
                                                   , getMDString
                                                   ) where

import Data.ByteString.Lazy.Char8 (ByteString)
import Data.LLVM.Private.PlaceholderTypes

getInt :: Constant -> Integer
getInt (ConstValue (ConstantInt i) (TypeInteger _)) = i
getInt c = error ("Constant is not an int: " ++ show c)

getBool :: Constant -> Bool
getBool (ConstValue (ConstantInt i) (TypeInteger 1)) = i == 1
getBool c = error ("Constant is not a bool: " ++ show c)

getMDString :: Constant -> ByteString
getMDString (ConstValue (MDString txt) TypeMetadata) = txt
getMDString c = error ("Not a constant metadata string: " ++ show c)
