//
//  State.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/27.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

class LuaStack {
    private(set) var slots: [LuaValueConvertible] = []
    // 表示当前栈顶
    var top: Int = 0
    
    var prev: LuaStack? = nil
    var closure: LuaClosure!
    var varargs: [LuaValueConvertible] = []
    var openuvs: [Int: LuaClosureUpvalue] = [:]
    var pc: Int = 0
    weak var state: LuaStateInstance!
    
    init(size: Int, state: LuaStateInstance) {
        self.slots = [LuaValueConvertible].init(repeating: luaNil, count: size)
        self.state = state
    }
    
    func check(n: Int) {
        var left = self.slots.count - top
        while left < n {
            self.slots.append(luaNil)
            left += 1
        }
    }
    
    func push(value: LuaValueConvertible) {
        if self.top >= self.slots.count {
            fatalError("stack overflow")
        }
        self.slots[self.top] = value
        self.top += 1
    }
    
    @discardableResult
    func pop() -> LuaValueConvertible {
        if self.top < 1 {
            fatalError("stack underflow")
        }
        self.top -= 1
        let value = self.slots[self.top]
        self.slots[self.top] = luaNil
        return value
    }
    
    // 把索引换成绝对索引(没有考虑索引是否有效)
    func absIndex(idx: Int) -> Int {
        if idx <= LUA_REGISTRYINDEX { // 说明是伪索引
            return idx
        }
        if idx >= 0 {
            return idx
        }
        return idx + self.top + 1
    }
    
    // 判断索引是否有效
    func isValid(idx: Int) -> Bool {
        if idx < LUA_REGISTRYINDEX {
            let uvIdx = LUA_REGISTRYINDEX - idx - 1
            if let c = self.closure {
                return uvIdx < c.upvalue.count
            } else {
                return false
            }
        }
        if idx == LUA_REGISTRYINDEX {
            return true
        }
        let absIdx = self.absIndex(idx: idx)
        return absIdx > 0 && absIdx <= self.top
    }
    
    // 根据索引从栈里取值
    func get(idx: Int) -> LuaValueConvertible {
        if idx < LUA_REGISTRYINDEX {
            let uvIdx = LUA_REGISTRYINDEX - idx - 1
            if let c = self.closure, uvIdx < c.upvalue.count {
                return c.upvalue[uvIdx].val
            } else {
                return luaNil
            }
        }
        if idx == LUA_REGISTRYINDEX {
            return self.state.registry
        }
        let absIdx = self.absIndex(idx: idx)
        if absIdx > 0 && absIdx <= self.top {
            return self.slots[absIdx - 1]
        }
        fatalError("error index get value")
    }
    
    // 根据索引向栈里写入值
    func set(idx: Int, val: LuaValueConvertible) {
        if idx < LUA_REGISTRYINDEX {
            let uvIdx = LUA_REGISTRYINDEX - idx - 1
            if let c = self.closure, uvIdx < c.upvalue.count {
                self.closure.upvalue[uvIdx] = LuaClosureUpvalue(val: val)
            }
            
        }
        if idx == LUA_REGISTRYINDEX {
            if let table = val as? LuaTable {
                self.state.registry = table
            } else {
                fatalError("cannot set registry")
            }
            return
        }
        let absIdx = self.absIndex(idx: idx)
        if absIdx > 0 && absIdx <= self.top {
            self.slots[absIdx - 1] = val
            return
        }
        fatalError("invalid index!")
    }
    
    func reverse(from idx1: Int, to idx2: Int) {
        let range = idx1 < idx2 ? idx1...idx2 : idx2...idx1
        self.slots.replaceSubrange(range,
                                   with: self.slots[range].reversed())
    }
    
    func popN(n: Int) -> [LuaValueConvertible] {
        var vals = [LuaValueConvertible].init(repeating: luaNil, count: n)
        for i in 0..<n {
            vals[n-1-i] = self.pop()
        }
        return vals
    }
    
    func pushN(vals: [LuaValueConvertible], n: Int) {
        let nVals = vals.count
        var nArgs = n
        if nArgs < 0 { nArgs = nVals }
        for i in 0..<nArgs {
            if i < nVals {
                self.push(value: vals[i])
            } else {
                self.push(value: luaNil)
            }
        }
    }
}
