//
//  LuaStateInstance.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/27.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Cocoa

class LuaStateInstance: LuaState {
    var stack: LuaStack
    private(set) var pc: Int
    var proto: Prototype
    
    init(size: Int = 20, proto: Prototype) {
        stack = LuaStack.init(size: size)
        pc = 0
        self.proto = proto
    }
    
    // 修改PC （用于实现跳转指令）
    func addPC(n: Int) {
        self.pc += n
    }
    
    func fetch() -> UInt32 {
        let i = self.proto.Code[self.pc]
        self.pc += 1
        return i
    }
    
    func getConst(idx: Int) {
        let c = self.proto.Constants[idx]
        if let value = c.value as? LuaValueType {
            self.stack.push(value: value)
        } else {
            fatalError("get constant error: \(c.value) is not a Const")
        }
    }
    
    func getRK(rk: Int) {
        if rk < 0xff {
            self.getConst(idx: rk & 0xff)
        } else {
            self.push(value: rk + 1)
        }
    }
    
    func getTop() -> Int {
        return self.stack.top
    }
    
    func absIdx(idx: Int) -> Int {
        return self.stack.absIndex(idx: idx)
    }
    
    func checkStack(n: Int) -> Bool {
        self.stack.check(n: n)
        return true
    }
    
    func pop(n: Int) {
        self.setTop(idx: -n-1)
    }
    
    func copy(from idx1: Int, to idx2: Int) {
        guard let val = self.stack.get(idx: idx1) else {
            fatalError("fromIndex no value")
        }
        self.stack.set(idx: idx2, val: val)
    }
    
    func push(value idx: Int) {
        guard let value = self.stack.get(idx: idx) else {
            fatalError("value cannot be nil")
        }
        self.stack.push(value: value)
    }
    
    func replace(idx: Int) {
        let val = self.stack.pop()
        self.stack.set(idx: idx, val: val)
    }
    
    // 其实就是将栈顶值弹出，然后插入指定位置
    func insert(idx: Int) {
        self.rotate(idx: idx, n: 1)
    }
    
    func remove(idx: Int) {
        self.rotate(idx: idx, n: -1)
        self.pop(n: 1)
    }
    
    func rotate(idx: Int, n: Int) {
        let t = self.stack.top - 1
        let p = self.stack.absIndex(idx: idx) - 1
        let m: Int
        if n >= 0 {
            m = t - n
        } else {
            m = p - n - 1
        }
        self.stack.reverse(from: p, to: m)
        self.stack.reverse(from: m + 1, to: t)
        self.stack.reverse(from: p, to: t)
    }
    // 将栈顶索引设置为指定值，如果指定值小于栈顶索引，效果则相当于弹出，如果大于栈顶索引，则要推入多个nil值
    func setTop(idx: Int) {
        let newTop = self.stack.absIndex(idx: idx)
        if newTop < 0 {
            fatalError("stack underflow!")
        }
        let n = self.stack.top - newTop
        if n > 0 {
            for _ in 0..<n {
                _ = self.stack.pop()
            }
        } else if n < 0 {
            (n..<0).forEach { (_) in
                self.stack.push(value: luaNil)
            }
        }
        
    }
    
    func typeName(tp: LuaType) -> String {
        return tp.name()
    }
    
    func type(idx: Int) -> LuaType {
        if self.stack.isValid(idx: idx) {
            if let value = self.stack.get(idx: idx) {
                return value.type
            }
        }
        return .none
    }
    
    func isNone(idx: Int) -> Bool {
        return self.type(idx: idx) == .none
    }
    
    func isNil(idx: Int) -> Bool {
        return self.type(idx: idx) == .nil_
    }
    
    func isNoneOrNil(idx: Int) -> Bool {
        let type = self.type(idx: idx)
        return type == .none || type == .nil_
    }
    
    func convertToBoolean(val: LuaValueType) -> Bool {
        switch val.type {
        case .nil_:
            return false
        case .boolean:
            return val as? Bool ?? false
        default:
            return true
        }
    }
    
    func isBoolean(idx: Int) -> Bool {
        return self.type(idx: idx) == .boolean
    }
    
    func isInteger(idx: Int) -> Bool {
        let val = self.stack.get(idx: idx)
        return val is Int
    }
    
    func isNumber(idx: Int) -> Bool {
        let (_, ok) = self.toNumberX(idx: idx)
        return ok
    }
    
    func isString(idx: Int) -> Bool {
        let type = self.type(idx: idx)
        // 可以类型转换
        return type == .string || type == .nubmer
    }
    
    func toBoolean(idx: Int) -> Bool {
        guard let val = self.stack.get(idx: idx) else {
            return false
        }
        return convertToBoolean(val: val)
    }
    
    func toInteger(idx: Int) -> Int64 {
        let (n, _) = self.toIntegerX(idx: idx)
        return n
    }
    
    func toIntegerX(idx: Int) -> (Int64, Bool) {
        guard let val = self.stack.get(idx: idx) else {
            fatalError("idx of stack no value")
        }
        if let v = val as? Int64 {
            return (v, true)
        }
        return (0, false)
    }
    
    func toNumber(idx: Int) -> Float64 {
        let (n, _) = self.toNumberX(idx: idx)
        return n
    }
    
    func toNumberX(idx: Int) -> (Float64, Bool) {
        guard let val = self.stack.get(idx: idx) else {
            fatalError("idx of stack no value")
        }
        if let f = val as? Float64 {
            return (f, true)
        }
        if let i = val as? Int64 {
            return (Float64(i), true)
        }
        return (0, false)
    }
    
    func toString(idx: Int) -> String {
        let (s, _) = self.toStringX(idx: idx)
        return s
    }
    
    func toStringX(idx: Int) -> (String, Bool) {
        guard let val = self.stack.get(idx: idx) else {
            fatalError("idx of stack no value")
        }
        if let s = val as? String {
            return (s, true)
        }
        if let i = val as? Int64 {
            let s = "\(i)"
            self.stack.set(idx: idx,
                           val: s)
            return (s, true)
        }
        if let i = val as? Float64 {
            let s = "\(i)"
            self.stack.set(idx: idx,
                           val: s)
            return (s, true)
        }
        return ("", false)
    }
    
    func pushNil() {
        self.stack.push(value: luaNil)
    }
    
    func pushBoolean(b: Bool) {
        self.stack.push(value: b)
    }
    
    func pushInteger(n: Int64) {
        self.stack.push(value: n)
    }
    
    func pushNumber(f: Float64) {
        self.stack.push(value: f)
    }
    
    func pushString(s: String) {
        self.stack.push(value: s)
    }
    
}

// MARK: - Arith Operation
extension LuaStateInstance {
    func arith(op: ArithOperator) {
        do {
            let a, b: LuaValueType
            b = self.stack.pop()
            let result: LuaValueType
            if op != .unm && op != .bNot {
                a = self.stack.pop()
                result = try op.action(lhs: a, rhs: b)
            } else {
                result = try op.action(lhs: b)
            }
            self.stack.push(value: result)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        
    }
    func compare(idx1: Int, idx2: Int, op: CompareOperator) -> Bool {
        guard let a = self.stack.get(idx: idx1), let b = self.stack.get(idx: idx2) else {
            fatalError("error get value from stack")
        }
        return op.action(v1: a, v2: b)
    }
    func len(idx: Int) {
        guard let value = self.stack.get(idx: idx) else { fatalError("error get value from stack") }
        if let v = value as? String {
            self.stack.push(value: Int64(v.count))
        } else {
            fatalError("error get length")
        }
    }
    func concat(n: Int) {
        if n == 0 {
            self.stack.push(value: "")
        } else if n >= 2 {
            for _ in 1..<n {
                if self.isString(idx: -1) && self.isString(idx: -2) {
                    let s2 = self.toString(idx: -1)
                    let s1 = self.toString(idx: -2)
                    self.stack.pop()
                    self.stack.pop()
                    self.stack.push(value: s1 + s2)
                } else {
                    fatalError("concatenation error!")
                }
            }
        }
        // TODO: n = 1
    }
}
