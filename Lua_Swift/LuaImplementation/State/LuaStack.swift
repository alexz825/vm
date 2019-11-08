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
    var pc: Int = 0
    
    init(size: Int) {
        self.slots = [LuaValueConvertible].init(repeating: luaNil, count: size)
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
        if idx >= 0 {
            return idx
        }
        return idx + self.top + 1
    }
    
    // 判断索引是否有效
    func isValid(idx: Int) -> Bool {
        let absIdx = self.absIndex(idx: idx)
        return absIdx > 0 && absIdx <= self.top
    }
    // 根据索引从栈里取值
    func get(idx: Int) -> LuaValueConvertible {
        let absIdx = self.absIndex(idx: idx)
        if absIdx > 0 && absIdx <= self.top {
            return self.slots[absIdx - 1]
        }
        fatalError("error index get value")
//        return luaNone
    }
    // 根据索引向栈里写入值
    func set(idx: Int, val: LuaValueConvertible) {
        let absIdx = self.absIndex(idx: idx)
        if absIdx > 0 && absIdx <= self.top {
            self.slots[absIdx - 1] = val
            return
        }
        fatalError("invalid index!")
    }
    
    func reverse(from idx1: Int, to idx2: Int) {
        self.slots.replaceSubrange(idx1...idx2,
                                   with: self.slots[idx1...idx2].reversed())
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
