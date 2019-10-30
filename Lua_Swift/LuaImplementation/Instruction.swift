//
//  Instruction.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/24.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Cocoa

private let MAXARG_Bx = (1 << 18) - 1 // 2^18 - 1
private let MAXARG_sBx = MAXARG_Bx >> 1 // (2^18 - 1) / 2

typealias Instruction = UInt32


extension Instruction {
    // 从指令中提取操作码
    func opCode() -> Int {
        return Int(self & 0x3f)
    }
    
    // 从iABC模式指令中提取参数
    func ABC() -> (a: Int, b: Int, c: Int) {
        let a = Int(self >> 6 & 0xff)
        let b = Int(self >> 14 & 0x1ff)
        let c = Int(self >> 23 & 0x1ff)
        return (a: a, b: b, c: c)
    }
    
    func ABx() -> (a: Int, bx: Int) {
        let a = Int(self >> 6 & 0xff)
        let bx = Int(self >> 14)
        return (a: a, bx: bx)
    }
    
    func AsBx() -> (a: Int, sbx: Int) {
        let (a, bx) = self.ABx() // 偏移二进制码 (如果是无符号整数值是x，如果是有符号整数值是x-K)
        return (a: a, sbx: bx - MAXARG_sBx)
    }
    
    func Ax() -> Int {
        return Int(self >> 6)
    }
    
    func opName() -> String {
        return opCodes[self.opCode()].name
    }
    
    func opMode() -> OpMode {
        return opCodes[self.opCode()].opMode
    }
    
    func cMode() -> OpArgMode {
        return opCodes[self.opCode()].argBMode
    }
    
    func bMode() -> OpArgMode {
        return opCodes[self.opCode()].argCMode
    }
}
