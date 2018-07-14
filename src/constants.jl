# Floating point data format invariants

const SIGN_BIT = 0x80000000
const SIGN_BIT_64 = UInt64(SIGN_BIT)

const bmask16 = 0xFFFF
const bmask32 = 0xFFFFFFFF

const UNO = one(UInt32)
const UNO64 = one(UInt64)

# VAX floating point data formats (see VAX Architecture Reference Manual)

const VAX_F_SIGN_BIT      = SIGN_BIT
const VAX_F_EXPONENT_MASK = UInt32(0x7F800000)
const VAX_F_EXPONENT_SIZE = UInt32(8)
const VAX_F_EXPONENT_BIAS = UInt32(128)
const VAX_F_MANTISSA_MASK = UInt32(0x007FFFFF)
const VAX_F_MANTISSA_SIZE = UInt32(23)
const VAX_F_HIDDEN_BIT    = UInt32( UNO << VAX_F_MANTISSA_SIZE )

const VAX_D_EXPONENT_MASK = UInt64(VAX_F_EXPONENT_MASK)
const VAX_D_EXPONENT_SIZE = UInt64(VAX_F_EXPONENT_SIZE)
const VAX_D_EXPONENT_BIAS = UInt64(VAX_F_EXPONENT_BIAS)
const VAX_D_MANTISSA_MASK = UInt64(VAX_F_MANTISSA_MASK)
const VAX_D_MANTISSA_SIZE = UInt64(VAX_F_MANTISSA_SIZE)
const VAX_D_HIDDEN_BIT    = UInt64(VAX_F_HIDDEN_BIT)

const VAX_G_EXPONENT_MASK = UInt64(0x7FF00000)
const VAX_G_EXPONENT_SIZE = UInt64(11)
const VAX_G_EXPONENT_BIAS = UInt64(1024)
const VAX_G_MANTISSA_MASK = UInt64(0x000FFFFF)
const VAX_G_MANTISSA_SIZE = UInt64(20)
const VAX_G_HIDDEN_BIT    = UInt64( UNO << VAX_G_MANTISSA_SIZE )

# IEEE floating point data formats (see Alpha Architecture Reference Manual)

const IEEE_S_SIGN_BIT      = SIGN_BIT
const IEEE_S_EXPONENT_MASK = UInt32(0x7F800000)
const IEEE_S_EXPONENT_SIZE = UInt32(8)
const IEEE_S_EXPONENT_BIAS = UInt32(127)
const IEEE_S_MANTISSA_MASK = UInt32(0x007FFFFF)
const IEEE_S_MANTISSA_SIZE = UInt32(23)
const IEEE_S_HIDDEN_BIT    = UInt32( UNO << IEEE_S_MANTISSA_SIZE )

const IEEE_T_EXPONENT_MASK = UInt64(0x7FF00000)
const IEEE_T_EXPONENT_SIZE = UInt64(11)
const IEEE_T_EXPONENT_BIAS = UInt64(1023)
const IEEE_T_MANTISSA_MASK = UInt64(0x000FFFFF)
const IEEE_T_MANTISSA_SIZE = UInt64(20)
const IEEE_T_HIDDEN_BIT    = UInt64( 1 << IEEE_T_MANTISSA_SIZE )

