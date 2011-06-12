module Data.LLVM.Private.AttributeTypes ( LinkageType(..)
                                        , CallingConvention(..)
                                        , VisibilityStyle(..)
                                        , ParamAttribute(..)
                                        , FunctionAttribute(..)
                                        , Endian(..)
                                        , ArithFlag(..)
                                        , DataLayout(..)
                                        , TargetTriple(..)
                                        , AlignSpec(..)
                                        , defaultDataLayout
                                        , GCName(..)
                                        , ICmpCondition(..)
                                        , FCmpCondition(..)
                                        , GlobalAnnotation(..)
                                        , Assembly(..)
                                        , module Data.LLVM.Private.Identifiers
                                        ) where

import Data.ByteString.Char8 ( ByteString, unpack )
import Data.Hashable

import Data.LLVM.Private.Identifiers

data Assembly = Assembly ByteString
                deriving (Eq, Ord)

instance Show Assembly where
  show (Assembly txt) = unpack txt


data LinkageType = LTPrivate
                 | LTLinkerPrivate
                 | LTLinkerPrivateWeak
                 | LTLinkerPrivateWeakDefAuto
                 | LTInternal
                 | LTAvailableExternally
                 | LTLinkOnce
                 | LTWeak
                 | LTCommon
                 | LTAppending
                 | LTExternWeak
                 | LTLinkOnceODR
                 | LTWeakODR
                 | LTExtern -- Default
                 | LTDLLImport
                 | LTDLLExport
                   deriving (Eq, Ord)

instance Hashable LinkageType where
  hash LTPrivate = 1
  hash LTLinkerPrivate = 2
  hash LTLinkerPrivateWeak = 3
  hash LTLinkerPrivateWeakDefAuto = 4
  hash LTInternal = 5
  hash LTAvailableExternally = 6
  hash LTLinkOnce = 7
  hash LTWeak = 8
  hash LTCommon = 9
  hash LTAppending = 10
  hash LTExternWeak = 11
  hash LTLinkOnceODR = 12
  hash LTWeakODR = 13
  hash LTExtern = 14
  hash LTDLLImport = 15
  hash LTDLLExport = 16

instance Show LinkageType where
  show LTPrivate = "private"
  show LTLinkerPrivate = "linker_private"
  show LTLinkerPrivateWeak = "linker_private_weak"
  show LTLinkerPrivateWeakDefAuto = "linker_private_weak_def_auto"
  show LTInternal = "internal"
  show LTAvailableExternally = "available_externally"
  show LTLinkOnce = "link_once"
  show LTWeak = "weak"
  show LTCommon = "common"
  show LTAppending = "appending"
  show LTExternWeak = "extern_weak"
  show LTLinkOnceODR = "link_once_odr"
  show LTWeakODR = "weak_odr"
  show LTExtern = ""
  show LTDLLImport = "dllimport"
  show LTDLLExport = "dllexport"

data CallingConvention = CCC
                       | CCFastCC
                       | CCColdCC
                       | CCGHC
                       | CCN !Int
                       deriving (Eq, Ord)

instance Show CallingConvention where
  show CCC = ""
  show CCFastCC = "fastcc"
  show CCColdCC = "coldcc"
  show CCGHC = "cc 10"
  show (CCN n) = "cc " ++ show n

data VisibilityStyle = VisibilityDefault
                     | VisibilityHidden
                     | VisibilityProtected
                       deriving (Eq, Ord)

instance Show VisibilityStyle where
  show VisibilityDefault = ""
  show VisibilityHidden = "hidden"
  show VisibilityProtected = "protected"

instance Hashable VisibilityStyle where
  hash VisibilityDefault = 1
  hash VisibilityHidden = 2
  hash VisibilityProtected = 3

data ParamAttribute = PAZeroExt
                    | PASignExt
                    | PAInReg
                    | PAByVal
                    | PASRet
                    | PANoAlias
                    | PANoCapture
                    | PANest
                    | PAAlign !Int
                    deriving (Eq, Ord)

instance Show ParamAttribute where
  show PAZeroExt = "zeroext"
  show PASignExt = "signext"
  show PAInReg = "inreg"
  show PAByVal = "byval"
  show PASRet = "sret"
  show PANoAlias = "noalias"
  show PANoCapture = "nocapture"
  show PANest = "nest"
  show (PAAlign i) = "align " ++ show i

data FunctionAttribute = FAAlignStack !Int
                       | FAAlwaysInline
                       | FAHotPatch
                       | FAInlineHint
                       | FANaked
                       | FANoImplicitFloat
                       | FANoInline
                       | FANoRedZone
                       | FANoReturn
                       | FANoUnwind
                       | FAOptSize
                       | FAReadNone
                       | FAReadOnly
                       | FASSP
                       | FASSPReq
                       deriving (Eq, Ord)

instance Show FunctionAttribute where
  show (FAAlignStack n) = "alignstack(" ++ show n ++ ")"
  show FAAlwaysInline = "alwaysinline"
  show FAHotPatch = "hotpatch"
  show FAInlineHint = "inlinehint"
  show FANaked = "naked"
  show FANoImplicitFloat = "noimplicitfloat"
  show FANoInline = "noinline"
  show FANoRedZone = "noredzone"
  show FANoReturn = "noreturn"
  show FANoUnwind = "nounwind"
  show FAOptSize = "optsize"
  show FAReadNone = "readnone"
  show FAReadOnly = "readonly"
  show FASSP = "ssp"
  show FASSPReq = "sspreq"

data Endian = EBig
            | ELittle
              deriving (Eq, Ord)

instance Show Endian where
  show EBig = "E"
  show ELittle = "e"

-- Track the ABI alignment and preferred alignment
data AlignSpec = AlignSpec Int Int
                 deriving (Show, Eq, Ord)

data TargetTriple = TargetTriple ByteString
                    deriving (Eq)

instance Show TargetTriple where
  show (TargetTriple t) = unpack t

data DataLayout = DataLayout { endianness :: Endian
                             , pointerAlign :: (Int, AlignSpec)
                             , intAlign :: [ (Int, AlignSpec) ]
                             , vectorAlign :: [ (Int, AlignSpec) ]
                             , floatAlign :: [ (Int, AlignSpec) ]
                             , aggregateAlign :: [ (Int, AlignSpec) ]
                             , stackAlign :: [ (Int, AlignSpec) ]
                             , nativeWidths :: [ Int ]
                             }
                  deriving (Show, Eq)

-- Defaults specified by LLVM.  I think there can only be one pointer
-- align specification, though it isn't explicitly stated
defaultDataLayout :: DataLayout
defaultDataLayout = DataLayout { endianness = EBig
                               , pointerAlign = (64, AlignSpec 64 64)
                               , intAlign = [ (1, AlignSpec 8 8)
                                            , (8, AlignSpec 8 8)
                                            , (16, AlignSpec 16 16)
                                            , (32, AlignSpec 32 32)
                                            , (64, AlignSpec 32 64)
                                            ]
                               , vectorAlign = [ (64, AlignSpec 64 64)
                                               , (128, AlignSpec 128 128)
                                               ]
                               , floatAlign = [ (32, AlignSpec 32 32)
                                              , (64, AlignSpec 64 64)
                                              ]
                               , aggregateAlign = [ (0, AlignSpec 0 1) ]
                               , stackAlign = [ (0, AlignSpec 64 64) ]
                               , nativeWidths = [] -- Set.empty
                               }

data GCName = GCName ByteString deriving (Eq, Ord)

instance Show GCName where
  show (GCName t) = "gc \"" ++ unpack t ++ "\""

data ICmpCondition = ICmpEq
                   | ICmpNe
                   | ICmpUgt
                   | ICmpUge
                   | ICmpUlt
                   | ICmpUle
                   | ICmpSgt
                   | ICmpSge
                   | ICmpSlt
                   | ICmpSle
                     deriving (Eq, Ord)

instance Hashable ICmpCondition where
  hash ICmpEq = 1
  hash ICmpNe = 2
  hash ICmpUgt = 3
  hash ICmpUge = 4
  hash ICmpUlt = 5
  hash ICmpUle = 6
  hash ICmpSgt = 7
  hash ICmpSge = 8
  hash ICmpSlt = 9
  hash ICmpSle = 10


instance Show ICmpCondition where
  show ICmpEq = "eq"
  show ICmpNe = "ne"
  show ICmpUgt = "ugt"
  show ICmpUge = "uge"
  show ICmpUlt = "ult"
  show ICmpUle = "ule"
  show ICmpSgt = "sgt"
  show ICmpSge = "sge"
  show ICmpSlt = "slt"
  show ICmpSle = "sle"

data FCmpCondition = FCmpFalse
                   | FCmpOeq
                   | FCmpOgt
                   | FCmpOge
                   | FCmpOlt
                   | FCmpOle
                   | FCmpOne
                   | FCmpOrd
                   | FCmpUeq
                   | FCmpUgt
                   | FCmpUge
                   | FCmpUlt
                   | FCmpUle
                   | FCmpUne
                   | FCmpUno
                   | FCmpTrue
                     deriving (Eq, Ord)

instance Hashable FCmpCondition where
  hash FCmpFalse = 1
  hash FCmpOeq = 2
  hash FCmpOgt = 3
  hash FCmpOge = 4
  hash FCmpOlt = 5
  hash FCmpOle = 6
  hash FCmpOne = 7
  hash FCmpOrd = 8
  hash FCmpUeq = 9
  hash FCmpUgt = 10
  hash FCmpUge = 11
  hash FCmpUlt = 12
  hash FCmpUle = 13
  hash FCmpUne = 14
  hash FCmpUno = 15
  hash FCmpTrue = 16

instance Show FCmpCondition where
  show FCmpFalse = "false"
  show FCmpOeq = "oeq"
  show FCmpOgt = "ogt"
  show FCmpOge = "oge"
  show FCmpOlt = "olt"
  show FCmpOle = "ole"
  show FCmpOne = "one"
  show FCmpOrd = "ord"
  show FCmpUeq = "ueq"
  show FCmpUgt = "ugt"
  show FCmpUge = "uge"
  show FCmpUlt = "ult"
  show FCmpUle = "ule"
  show FCmpUne = "une"
  show FCmpUno = "uno"
  show FCmpTrue = "true"

data GlobalAnnotation = GAConstant
                      | GAGlobal
                        deriving (Eq, Ord)

instance Show GlobalAnnotation where
  show GAConstant = "constant"
  show GAGlobal = "global"

data ArithFlag = AFNSW | AFNUW
               deriving (Eq, Ord)

instance Show ArithFlag where
  show AFNSW = "nsw"
  show AFNUW = "nuw"
