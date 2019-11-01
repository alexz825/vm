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
    
    func move(vm: LuaVM) {
        var (a, b, _) = self.ABC()
        a += 1
        b += 1
        vm.state.copy(from: b, to: a)
    }
    
    func jmp(vm: LuaVM) {
        let (a, sBx) = self.AsBx()
        vm.addPC(n: sBx)
        if a != 0 {
            fatalError("toto")
        }
    }
    
    func loadNil(vm: LuaVM) {
        var (a, b, _) = self.ABC()
        a += 1
        vm.state.pushNil()
        for i in a..<(a+b) {
            vm.state.copy(from: -1, to: i)
        }
        vm.state.pop(n: 1)
    }
    
    func loadBool(vm: LuaVM) {
        var (a, b, c) = self.ABC()
        a += 1
        vm.state.pushBoolean(b: b != 0)
        vm.state.replace(idx: a)
        if c != 0 {
            vm.addPC(n: 1)
        }
    }
    
    func loadK(vm: LuaVM) {
        var (a, bx) = self.ABx()
        a += 1
        vm.getConst(idx: bx)
        vm.state.replace(idx: a)
    }
    
    func loadKx(vm: LuaVM) {
        var (a, _) = self.ABx()
        a += 1
        let ax  = Instruction(vm.state.fetch()).Ax()
        vm.state.getConst(idx: ax)
        vm.state.replace(idx: a)
    }
}
