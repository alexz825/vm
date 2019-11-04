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

/*
 31       22       13       5    0
 +-------+^------+-^-----+-^-----
 |b=9bits |c=9bits |a=8bits|op=6|
 +-------+^------+-^-----+-^-----
 |    bx=18bits    |a=8bits|op=6|
 +-------+^------+-^-----+-^-----
 |   sbx=18bits    |a=8bits|op=6|
 +-------+^------+-^-----+-^-----
 |    ax=26bits            |op=6|
 +-------+^------+-^-----+-^-----
 31      23      15       7      0
 */

extension Instruction {
    // 从指令中提取操作码
    var opCodeInt: Int {
        return Int(self & 0x3f)
    }
    
    var opCode: OpCode {
        return opCodes[self.opCodeInt]
    }
    
    // 从iABC模式指令中提取参数
    func ABC() -> (a: Int, b: Int, c: Int) {
        let a = Int(self >> 6 & 0xff)
        let c = Int(self >> 14 & 0x1ff)
        let b = Int(self >> 23 & 0x1ff)
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
        return opCode.name
    }
    
    func opMode() -> OpMode {
        return opCode.opMode
    }
    
    func cMode() -> OpArgMode {
        return opCode.argBMode
    }
    
    func bMode() -> OpArgMode {
        return opCode.argCMode
    }
    
    func excute(vm: LuaVM) {
        let op = opCode
        let action: ((_ vm: LuaVM) -> Void)!
        switch op.opCode {
        case .move:
            action = self.move
        case .loadK:
            action = self.loadK
        case .loadKX:
            action = self.loadKx
        case .loadBool:
            action = self.loadBool
        case .loadNil:
            action = self.loadNil
        case .add:
            action = self.add
        case .sub:
            action = self.sub
        case .mul:
            action = self.mul
        case .mod:
            action = self.mod
        case .pow:
            action = self.mod
        case .div:
            action = self.div
        case .iDiv:
            action = self.iDiv(vm:)
        case .bAnd:
            action = self.bAnd(vm:)
        case .bOr:
            action = self.bOr(vm:)
        case .bXor:
            action = self.bXor(vm:)
        case .shL:
            action = self.shl(vm:)
        case .shR:
            action = self.shr(vm:)
        case .unm:
            action = self.unm(vm:)
        case .bNot:
            action = self.bNot(vm:)
        case .not:
            action = self.not(vm:)
        case .len:
            action = self.len(vm:)
        case .concat:
            action = self.concat(vm:)
        case .jmp:
            action = self.jmp(vm:)
        case .eq:
            action = self.eq(vm:)
        case .lt:
            action = self.lt(vm:)
        case .le:
            action = self.len(vm:)
        case .test:
            action = self.test(vm:)
        case .testSet:
            action = self.testSet(vm:)
        case .forLoop:
            action = self.forLoop(vm:)
        case .forPrep:
            action = self.forPrep(vm:)
        case .getUpVal, .getTabUp, .getTable:
            action = nil
        case .setTabUp, .setUpVal, .setTable, .newTable:
            action = nil
        case .self_:
            action = nil
        case .call, .tailCall, .return_:
            action = nil
        case .tForCall, .tForLoop, .setList, .closure:
            action = nil
        case .varArg, .extraArg:
            action = nil
        }
        if action != nil {
            action(vm)            
        }
    }
}

// MARK: - 操作指令的实现 1
extension Instruction {
    func move(vm: LuaVM) {
        var (a, b, _) = self.ABC()
        a += 1
        b += 1
        vm.copy(from: b, to: a)
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
        vm.pushNil()
        for i in a..<(a+b) {
            vm.copy(from: -1, to: i)
        }
        vm.pop(n: 1)
    }
    
    func loadBool(vm: LuaVM) {
        var (a, b, c) = self.ABC()
        a += 1
        vm.pushBoolean(b: b != 0)
        vm.replace(idx: a)
        if c != 0 {
            vm.addPC(n: 1)
        }
    }
    
    //LOADK 指令( iABx 模式)将常量表里 的某个常量加载到指定寄存器，寄存器索引由 操作数 A 指定，常量表索引由操作数 Bx 指定 。
    func loadK(vm: LuaVM) {
        var (a, bx) = self.ABx()
        a += 1
        vm.getConst(idx: bx)
        vm.replace(idx: a)
    }
    //LOADKX指令(也是 iABx模式)需要和 EXTRAARG指令(iAx模式)搭配使用，用 后者的 Ax 操作数来指定常量索引 。
    func loadKx(vm: LuaVM) {
        var (a, _) = self.ABx()
        a += 1
        let ax  = Instruction(vm.fetch()).Ax()
        vm.getConst(idx: ax)
        vm.replace(idx: a)
    }
}

// MARK: - 操作指令实现 - 运算符
extension Instruction {
    func add(vm: LuaVM) { self.binaryArith(vm: vm, op: .add) }
    func sub(vm: LuaVM) { self.binaryArith(vm: vm, op: .sub) }
    func mul(vm: LuaVM) { self.binaryArith(vm: vm, op: .mul) }
    func mod(vm: LuaVM) { self.binaryArith(vm: vm, op: .mod) }
    func pow(vm: LuaVM) { self.binaryArith(vm: vm, op: .pow) }
    func div(vm: LuaVM) { self.binaryArith(vm: vm, op: .div) }
    func iDiv(vm: LuaVM) { self.binaryArith(vm: vm, op: .iDiv) }
    func bAnd(vm: LuaVM) { self.binaryArith(vm: vm, op: .bAnd) }
    func bOr(vm: LuaVM) { self.binaryArith(vm: vm, op: .bOr) }
    func bXor(vm: LuaVM) { self.binaryArith(vm: vm, op: .bXor) }
    func shl(vm: LuaVM) { self.binaryArith(vm: vm, op: .shl) }
    func shr(vm: LuaVM) { self.binaryArith(vm: vm, op: .shr) }
    func unm(vm: LuaVM) { self.unary(vm: vm, op: .unm) }
    func bNot(vm: LuaVM) { self.unary(vm: vm, op: .bNot) }
    
    private func binaryArith(vm: LuaVM, op: ArithOperator) {
        var (a, b, c) = self.ABC()
        a += 1
        vm.getRK(rk: b)
        vm.getRK(rk: c)
        vm.arith(op: op)
        vm.replace(idx: a)
    }
    
    private func unary(vm: LuaVM, op: ArithOperator) {
        var (a, b, _) = self.ABC()
        a += 1
        b += 1
        vm.push(value: b)
        vm.arith(op: op)
        vm.replace(idx: a)
    }
}

// MARK: 长度和拼接指令
extension Instruction {
    private func len(vm: LuaVM) {
        var (a, b, _) = self.ABC()
        a += 1
        b += 1
        vm.len(idx: b)
        vm.replace(idx: a)
    }
    
    func concat(vm: LuaVM) {
        var (a, b, c) = self.ABC()
        a += 1
        b += 1
        c += 1
        
        let n = c - b + 1
        vm.checkStack(n: n)
        for i in b..<c {
            vm.push(value: i)
        }
        vm.concat(n: n)
        vm.replace(idx: a)
    }
}

// MARK: 比较
extension Instruction {
    private func compare(vm: LuaVM, op: CompareOperator) {
        let (a, b, c) = self.ABC()
        vm.getRK(rk: b)
        vm.getRK(rk: c)
        if vm.compare(idx1: -2, idx2: -1, op: op) != (a != 0) {
            vm.addPC(n: 1)
        }
        vm.pop(n: 2)
    }
    
    func eq(vm: LuaVM) {
        compare(vm: vm, op: .eq)
    }
    
    func le(vm: LuaVM) {
        compare(vm: vm, op: .le)
    }
    
    func lt(vm: LuaVM) {
        compare(vm: vm, op: .lt)
    }
}

// Mark: 逻辑运算
extension Instruction {
    // NOT指令 (iABC模式)进行的操作和一元算术运算指令类似
    func not(vm: LuaVM) {
        var (a, b, _) = self.ABC()
        a += 1
        b += 1
        vm.pushBoolean(b: !vm.toBoolean(idx: b))
        vm.replace(idx: a)
    }
    
    // TESTSET 指令( iABC 模式)，判断寄存器 B (索引由操作数 B 指定)中的值转换为布 尔值之后是否和操作数 C 表示的布尔值一致，如果一致则将寄存器 B 中的值复制到寄存 器 A (索引由操作数 A 指定)中，否则跳过下一条指令 。
    func testSet(vm: LuaVM) {
        var (a, b, c) = self.ABC()
        a += 1
        b += 1
        if vm.toBoolean(idx: b) == (c != 0) {
            vm.copy(from: b, to: a)
        } else {
            vm.addPC(n: 1)
        }
    }
    
    // TEST指令(iABC模式)，判断寄存器A (索引由操作数A指定) 中的值转换为布尔 值之后是否和操作数 C 表示的布尔值一致，如果一致，则跳过下一条指令 。
    func test(vm: LuaVM) {
        var (a, _, c) = self.ABC()
        a += 1
        if vm.toBoolean(idx: a) != (c != 0) {
            vm.addPC(n: 1)
        }
    }
    
    func forPrep(vm: LuaVM) {
        var (a, sBx) = self.AsBx()
        a += 1
        // R(A) -= R(A+2)
        vm.push(value: a)
        vm.push(value: a + 2)
        vm.arith(op: .sub)
        vm.replace(idx: a)
        // pc += sBx
        vm.addPC(n: sBx)
    }
    
    func forLoop(vm: LuaVM) {
        var (a, sBx) = self.AsBx()
        a += 1
        // R(A) += R(A+2)
        vm.push(value: a + 2)
        vm.push(value: a)
        vm.arith(op: .add)
        vm.replace(idx: a)
        
        // R(A) <?= R(A+1)
        let isPositionStep = vm.toNumber(idx: a+2) >= 0
        if isPositionStep && vm.compare(idx1: a, idx2: a + 1, op: .le)
            || !isPositionStep && vm.compare(idx1: a + 1, idx2: a, op: .le) {
            vm.addPC(n: sBx)    // pc += sBx
            vm.copy(from: a, to: a + 3) // R(A+3)=R(A)
        }
    }
}
