//
//  OpCodes.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/24.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

enum OpMode: Int {
    case iABC = 0
    case iABx
    case iAsBx
    case iAx
}

enum OpCodeName: Int {
    case move = 0
    case loadK, loadKX, loadBool, loadNil
    case getUpVal, getTabUp, getTable
    case setTabUp, setUpVal, setTable
    case newTable
    case self_
    case add, sub, mul, mod, pow, div, iDiv
    case bAnd, bOr, bXor
    case shL, shR
    case unm, bNot, not
    case len
    case concat
    case jmp
    case eq, lt, le
    case test
    case testSet
    case call
    case tailCall
    case return_
    case forLoop
    case forPrep
    case tForCall
    case tForLoop
    case setList
    case closure
    case varArg
    case extraArg
}

enum OpArgMode: Int {
    case n // argument is not used
    case u // argument is used
    case r // argument is a register or a jumpoffset
    case k // argument is a constant or register/constant
}

struct OpCode {
    let testFlag: Byte // operator is a test (next instuction must be a jump)
    let setAFlag: Byte // instruction set register A
    let argBMode: OpArgMode // B arg mode
    let argCMode: OpArgMode // C arg mode
    let opMode: OpMode // op mode
    let name: String
    
    init(_ testFlag: Byte,
         _ setAFlag: Byte,
         _ argBMode: OpArgMode,
         _ argCMode: OpArgMode,
         _ opMode: OpMode,
         _ name: String) {
        self.testFlag = testFlag
        self.setAFlag = setAFlag
        self.argBMode = argBMode
        self.argCMode = argCMode
        self.opMode = opMode
        self.name = name
    }
}

var opCodes: [OpCode] =
[
    /***        T, A,  B,  c,  mode    name    */
    OpCode.init(0, 1, .r, .n, .iABC,  "MOVE    "),
    OpCode.init(0, 1, .k, .n, .iABx,  "LOADK   "),
    OpCode.init(0, 1, .n, .n, .iABx,  "LOADKX  "),
    OpCode.init(0, 1, .u, .u, .iABC,  "LOADBOOL"),
    OpCode.init(0, 1, .u, .n, .iABC,  "LOADNIL "),
    OpCode.init(0, 1, .u, .n, .iABC,  "GETUPVAL"),
    OpCode.init(0, 1, .u, .k, .iABC,  "GETTABUP"),
    OpCode.init(0, 1, .r, .k, .iABC,  "GETTABLE"),
    OpCode.init(0, 0, .k, .k, .iABC,  "SETTABUP"),
    OpCode.init(0, 0, .u, .n, .iABC,  "SETUPVAL"),
    OpCode.init(0, 0, .k, .k, .iABC,  "SETTABLE"),
    OpCode.init(0, 1, .u, .u, .iABC,  "NEWTABLE"),
    OpCode.init(0, 1, .r, .k, .iABC,  "SELF    "),
    OpCode.init(0, 1, .k, .k, .iABC,  "ADD     "),
    OpCode.init(0, 1, .k, .k, .iABC,  "SUB     "),
    OpCode.init(0, 1, .k, .k, .iABC,  "MUL     "),
    OpCode.init(0, 1, .k, .k, .iABC,  "MOD     "),
    OpCode.init(0, 1, .k, .k, .iABC,  "POW     "),
    OpCode.init(0, 1, .k, .k, .iABC,  "DIV     "),
    OpCode.init(0, 1, .k, .k, .iABC,  "IDIV    "),
    OpCode.init(0, 1, .k, .k, .iABC,  "BAND    "),
    OpCode.init(0, 1, .k, .k, .iABC,  "BOR     "),
    OpCode.init(0, 1, .k, .k, .iABC,  "BXOR    "),
    OpCode.init(0, 1, .k, .k, .iABC,  "SHL     "),
    OpCode.init(0, 1, .k, .k, .iABC,  "SHR     "),
    OpCode.init(0, 1, .r, .n, .iABC,  "UNM     "),
    OpCode.init(0, 1, .r, .n, .iABC,  "BNOT    "),
    OpCode.init(0, 1, .r, .n, .iABC,  "NOT     "),
    OpCode.init(0, 1, .r, .n, .iABC,  "LEN     "),
    OpCode.init(0, 1, .r, .n, .iABC,  "CONCAT"),
    OpCode.init(0, 1, .r, .n, .iAsBx, "JMP     "),
    OpCode.init(1, 0, .k, .k, .iABC,  "EQ      "),
    OpCode.init(1, 0, .k, .k, .iABC,  "LT      "),
    OpCode.init(1, 0, .k, .k, .iABC,  "LE      "),
    OpCode.init(1, 0, .n, .u, .iABC,  "TEST    "),
    OpCode.init(1, 1, .r, .u, .iABC,  "TESTSET "),
    OpCode.init(0, 1, .u, .u, .iABC,  "CALL    "),
    OpCode.init(0, 1, .u, .u, .iABC,  "TAILCALL"),
    OpCode.init(0, 0, .u, .n, .iABC,  "RETURN  "),
    OpCode.init(0, 1, .r, .n, .iAsBx, "FORLOOP "),
    OpCode.init(0, 1, .r, .n, .iAsBx, "FORPREP "),
    OpCode.init(0, 0, .n, .u, .iABC,  "TFORCALL"),
    OpCode.init(0, 1, .r, .n, .iAsBx, "TFORLOOP"),
    OpCode.init(0, 0, .u, .u, .iABC,  "SETLIST "),
    OpCode.init(0, 1, .u, .n, .iABx,  "CLOSURE "),
    OpCode.init(0, 1, .u, .n, .iABC,  "VARARG  "),
    OpCode.init(0, 0, .u, .u, .iAx,   "EXTRAARG"),
]
