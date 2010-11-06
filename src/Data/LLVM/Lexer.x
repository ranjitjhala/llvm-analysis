{
module Data.LLVM.Lexer ( lexer, Token(..) ) where

import Data.Binary.IEEE754
import Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as BS
import Data.ByteString.Internal (w2c)
import Data.Monoid
}

-- FIXME: Go through and conver all stored bytestrings into strict copies
-- so that the underlying input can be GCed.

%wrapper "basic-bytestring"

$digit = 0-9
$hexdigit = [$digit a-f A-F]
$alpha = [a-zA-Z]
$startChar = [$alpha \$ \. \_]
$identChar = [$startChar $digit]
$whitespace = [\ \t\b]
-- LLVM String characters are simple - quotes are represented as \22
-- (an ascii escape) so parsing them is simple
$stringChar = [^\"]

@decimal = [$digit]+
@quotedString = \" $stringChar* \"

tokens :-
  \n+ { const TNewline }
  $whitespace+ ;

  -- Identifiers
  "@" $startChar $identChar* { mkGlobalIdent }
  "%" $startChar $identChar* { mkLocalIdent }
  "!" $startChar $identChar* { mkMetadataName }
  -- Unnamed identifiers
  "@" @decimal+ { mkGlobalIdent }
  "%" @decimal+ { mkLocalIdent }
  "!" @decimal+ { mkMetadataName }
  -- Quoted string idents
  "@" @quotedString { mkQGlobalIdent }
  "%" @quotedString { mkQLocalIdent }

  -- Labels
  -- Drop the trailing : char
  $alpha+ ":" { TLabel . BS.init }

  -- Standard literals
  "-"? @decimal { mkIntLit }
  "-"? @decimal "." @decimal ("e" [\+\-]? @decimal)? { mkFloatLit }
  "0x"  $hexdigit+ { mkHexFloatLit 2 }
  "0xK" $hexdigit+ { mkHexFloatLit 3 }
  "0xM" $hexdigit+ { mkHexFloatLit 3 }
  "0xL" $hexdigit+ { mkHexFloatLit 3 }
  "c" @quotedString { mkStringConstant }
  "!" @quotedString { mkMetadataString }
  "true"  { const TTrueLit }
  "false" { const TFalseLit }
  "null"  { const TNullLit }
  "undef" { const TUndefLit }
  "zeroinitializer" { const TZeroInitializer }
  @quotedString { TString . unquote }


  -- Operator-like things
  ","   { const TComma }
  "="   { const TAssign }
  "*"   { const TStar }
  "("   { const TLParen }
  ")"   { const TRParen }
  "["   { const TLSquare }
  "]"   { const TRSquare }
  "{"   { const TLCurl }
  "}"   { const TRCurl }
  "<"   { const TLAngle }
  ">"   { const TRAngle }
  "!"   { const TBang }
  "x"   { const TAggLen }
  "to"  { const TTo }
  "..." { const TDotDotDot }

  -- Linkage Types
  "private"   { const TPrivate }
  "linker_private" { const TLinkerPrivate }
  "linker_private_weak" { const TLinkerPrivateWeak }
  "linker_private_weak_def_auto" { const TLinkerPrivateWeakDefAuto }
  "internal"  { const TInternal }
  "available_externally" { const TAvailableExternally }
  "linkonce"  { const TLinkOnce }
  "weak"      { const TWeak }
  "common"    { const TCommon }
  "appending" { const TAppending }
  "extern_weak" { const TExternWeak }
  "linkonce_odr" { const TLinkOnceODR }
  "weak_odr"  { const TWeakODR }
  "dllimport" { const TDLLImport }
  "dllexport" { const TDLLExport }

  -- Calling Conventions
  "ccc"    { const TCCCCC }
  "fastcc" { const TCCFastCC }
  "coldcc" { const TCCColdCC }
  "cc 10"  { const TCCGHC }
  "cc " @decimal { mkNumberedCC }

  -- Visibility styles
  "default"   { const TVisDefault }
  "hidden"    { const TVisHidden }
  "protected" { const TVisProtected }

  -- Parameter Attributes
  "zeroext"   { const TPAZeroExt }
  "signext"   { const TPASignExt }
  "inreg"     { const TPAInReg }
  "byval"     { const TPAByVal }
  "sret"      { const TPASRet }
  "noalias"   { const TPANoAlias }
  "nocapture" { const TPANoCapture }
  "nest"      { const TPANest }

  -- Function Attributes
  "alignstack(" @decimal ")" { mkAlignStack }
  "alwaysinline"    { const TFAAlwaysInline }
  "hotpatch"        { const TFAHotPatch }
  "inlinehint"      { const TFAInlineHint }
  "naked"           { const TFANaked }
  "noimplicitfloat" { const TFANoImplicitFloat }
  "noinline"        { const TFANoInline }
  "noredzone"       { const TFANoRedZone }
  "noreturn"        { const TFANoReturn }
  "nounwind"        { const TFANoUnwind }
  "optsize"         { const TFAOptSize }
  "readnone"        { const TFAReadNone }
  "readonly"        { const TFAReadOnly }
  "ssp"             { const TFASSP }
  "sspreq"          { const TFASSPReq }

  -- Types
  "i" @decimal { mkIntegralType }
  "float"      { const TFloatT }
  "double"     { const TDoubleT }
  "x86_fp80"   { const TX86_FP80T }
  "fp128"      { const TFP128T }
  "ppc_fp128"  { const TPPC_FP128T }
  "x86mmx"     { const TX86mmxT }
  "void"       { const TVoidT }
  "metadata"   { const TMetadataT }
  "opaque"     { const TOpaqueT }
  "label"      { const TLabelT }
  "\\" @decimal  { mkTypeUpref }


  -- Keyword-like things
  "addrspace(" @decimal ")" { mkAddrSpace }
  "type"       { const TType }
  "constant"   { const TConstant }
  "section"    { const TSection }
  "align"      { const TAlign }
  "alignstack" { const TAlignStack }
  "sideeffect" { const TSideEffect }
  "alias"      { const TAlias }
  "declare"    { const TDeclare }
  "define"     { const TDefine }
  "gc"         { const TGC }
  "module"     { const TModule }
  "asm"        { const TAsm }
  "target"     { const TTarget }
  "datalayout" { const TDataLayout }
  "blockaddress" { const TBlockAddress }
  "inbounds"   { const TInbounds }
  "global"     { const TGlobal }
  "appending"  { const TAppending }
  "nuw"        { const TNUW }
  "nsw"        { const TNSW }
  "exact"      { const TExact }
  "volatile"   { const TVolatile }

  -- Instructions
  "trunc"          { const TTrunc }
  "zext"           { const TZext }
  "sext"           { const TSext }
  "fptrunc"        { const TFpTrunc }
  "fpext"          { const TFpExt }
  "fptoui"         { const TFpToUI }
  "fptosi"         { const TFpToSI }
  "uitofp"         { const TUIToFp }
  "sitofp"         { const TSIToFp }
  "ptrtoint"       { const TPtrToInt }
  "inttoptr"       { const TIntToPtr }
  "bitcast"        { const TBitCast }
  "getelementptr"  { const TGetElementPtr }
  "select"         { const TSelect }
  "icmp"           { const TIcmp }
  "fcmp"           { const TFcmp }
  "extractelement" { const TExtractElement }
  "insertelement"  { const TInsertElement }
  "shufflevector"  { const TShuffleVector }
  "extractvalue"   { const TExtractValue }
  "insertvalue"    { const TInsertValue }
  "call"           { const TCall }
  "ret"            { const TRet }
  "br"             { const TBr }
  "switch"         { const TSwitch }
  "indirectbr"     { const TIndirectBr }
  "invoke"         { const TInvoke }
  "unwind"         { const TUnwind }
  "unreachable"    { const TUnreachable }
  "add"            { const TAdd }
  "fadd"           { const TFadd }
  "sub"            { const TSub }
  "fsub"           { const TFsub }
  "mul"            { const TMul }
  "fmul"           { const TFmul }
  "udiv"           { const TUdiv }
  "sdiv"           { const TSdiv }
  "fdiv"           { const TFdiv }
  "urem"           { const TUrem }
  "srem"           { const TSrem }
  "frem"           { const TFrem }
  "shl"            { const TShl }
  "lshr"           { const TLshr }
  "ashr"           { const TAshr }
  "and"            { const TAnd }
  "or"             { const TOr }
  "xor"            { const TXor }
  "alloca"         { const TAlloca }
  "load"           { const TLoad }
  "store"          { const TStore }
  "phi"            { const TPhi }
  "va_arg"         { const TVaArg }

{
data Token = TIntLit Integer
           | TFloatLit Double
           | TStringLit ByteString
           | TMetadataString ByteString
           | TTrueLit
           | TFalseLit
           | TNullLit
           | TUndefLit
           | TZeroInitializer
           | TString ByteString
           | TLabel ByteString
           | TNewline

           -- Operator-like tokens
           | TComma
           | TAssign
           | TStar
           | TLParen
           | TRParen
           | TLSquare
           | TRSquare
           | TLCurl
           | TRCurl
           | TLAngle
           | TRAngle
           | TBang
           | TAggLen
           | TTo
           | TDotDotDot

           -- Identifiers
           | TLocalIdent ByteString
           | TGlobalIdent ByteString
           | TMetadataName ByteString

           -- Linkage Types
           | TPrivate
           | TLinkerPrivate
           | TLinkerPrivateWeak
           | TLinkerPrivateWeakDefAuto
           | TInternal
           | TAvailableExternally
           | TLinkOnce
           | TWeak
           | TCommon
           | TAppending
           | TExternWeak
           | TLinkOnceODR
           | TWeakODR
           | TDLLImport
           | TDLLExport

           -- Calling Conventions
           | TCCCCC
           | TCCFastCC
           | TCCColdCC
           | TCCGHC
           | TCCN Int

           -- Visibility Style
           | TVisDefault
           | TVisHidden
           | TVisProtected

           -- Param Attributes
           | TPAZeroExt
           | TPASignExt
           | TPAInReg
           | TPAByVal
           | TPASRet
           | TPANoAlias
           | TPANoCapture
           | TPANest

           -- Function Attributes
           | TFAAlignStack Int
           | TFAAlwaysInline
           | TFAHotPatch
           | TFAInlineHint
           | TFANaked
           | TFANoImplicitFloat
           | TFANoInline
           | TFANoRedZone
           | TFANoReturn
           | TFANoUnwind
           | TFAOptSize
           | TFAReadNone
           | TFAReadOnly
           | TFASSP
           | TFASSPReq

           -- Types
           | TIntegralT Int -- bitsize
           | TFloatT
           | TDoubleT
           | TX86_FP80T
           | TFP128T
           | TPPC_FP128T
           | TX86mmxT
           | TVoidT
           | TMetadataT
           | TOpaqueT
           | TUprefT Int
           | TLabelT

           -- Keywords
           | TType
           | TAddrspace Int
           | TConstant
           | TSection
           | TAlign
           | TAlignStack
           | TSideEffect
           | TAlias
           | TDeclare
           | TDefine
           | TGC
           | TModule
           | TAsm
           | TTarget
           | TDataLayout
           | TBlockAddress
           | TInbounds
           | TGlobal

           -- Add modifiers
           | TNUW
           | TNSW

           -- Div mods
           | TExact

           -- Load/Store mods
           | TVolatile

           -- Instructions
           | TTrunc
           | TZext
           | TSext
           | TFpTrunc
           | TFpExt
           | TFpToUI
           | TFpToSI
           | TUIToFp
           | TSIToFp
           | TPtrToInt
           | TIntToPtr
           | TBitCast
           | TGetElementPtr
           | TSelect
           | TIcmp
           | TFcmp
           | TExtractElement
           | TInsertElement
           | TShuffleVector
           | TExtractValue
           | TInsertValue
           | TCall
           | TRet
           | TBr
           | TSwitch
           | TIndirectBr
           | TInvoke
           | TUnwind
           | TUnreachable
           | TAdd
           | TFadd
           | TSub
           | TFsub
           | TMul
           | TFmul
           | TUdiv
           | TSdiv
           | TFdiv
           | TUrem
           | TSrem
           | TFrem
           | TShl
           | TLshr
           | TAshr
           | TAnd
           | TOr
           | TXor
           | TAlloca
           | TLoad
           | TStore
           | TPhi
           | TVaArg
         deriving (Show)

-- Helpers for constructing identifiers
mkGlobalIdent = TGlobalIdent . stripSigil
mkLocalIdent = TLocalIdent . stripSigil
mkMetadataName = TMetadataName . stripSigil
mkQGlobalIdent = TGlobalIdent . unquote . stripSigil
mkQLocalIdent = TLocalIdent . unquote . stripSigil
mkQMetadataName = TMetadataName . unquote . stripSigil
stripSigil = BS.tail
unquote = BS.tail . BS.init

-- Helpers for the simple literals
mkIntLit s = TIntLit $ readBS s
mkFloatLit s = TFloatLit $ readBS s
-- Drop the first pfxLen characters (0x)
mkHexFloatLit pfxLen s = TFloatLit $ wordToDouble $ readBS s'
  where s' = "0x" `mappend` (BS.drop pfxLen s)
-- Strip off the leading c and then unquote
mkStringConstant = TStringLit . unquote . BS.tail
mkMetadataString = TMetadataString . unquote . BS.tail

readBS :: (Read a) => ByteString -> a
readBS = read . bs2s
bs2s s = map w2c $ BS.unpack s

-- Discard "cc "
mkNumberedCC s = TCCN $ readBS $ BS.drop 3 s

-- Extract part between parens (TFAAlignStack Int)
mkAlignStack s = TFAAlignStack $ readBS s'
  where s' = BS.drop 11 $ BS.init s

-- Types
mkTypeUpref s = TUprefT $ readBS $ BS.tail s
mkIntegralType s = TIntegralT $ readBS $ BS.tail s

mkAddrSpace s = TAddrspace $ readBS s'
  where s' = BS.drop 10 $ BS.init s

-- Exported interface
lexer = alexScanTokens

}