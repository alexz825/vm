//
//  State.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/27.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

struct LuaStack {
    private(set) var slots: [LuaValueConvertible] = []
    var top: Int {
        return self.slots.count
    }
    private var size: Int
    
    init(size: Int) {
        self.size = size
    }
    
    mutating func check(n: Int) {
        let left = size - top
        if left < n {
            size += (n - left)
        }
    }
    
    mutating func push(value: LuaValueConvertible) {
        if self.top == self.size {
            fatalError("stack overflow")
        }
        self.slots.append(value)
    }
    
    @discardableResult
    mutating func pop() -> LuaValueConvertible {
        if self.top < 1 {
            fatalError("stack underflow")
        }
        let value = self.slots.removeLast()
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
    func get(idx: Int) -> LuaValueConvertible? {
        let absIdx = self.absIndex(idx: idx)
        if absIdx > 0 && absIdx <= self.top {
            return self.slots[absIdx - 1]
        }
        return nil
    }
    // 根据索引向栈里写入值
    mutating func set(idx: Int, val: LuaValueConvertible) {
        let absIdx = self.absIndex(idx: idx)
        if absIdx > 0 && absIdx <= self.top {
            self.slots[absIdx - 1] = val
            return
        }
        fatalError("invalid index!")
    }
    
    mutating func reverse(from idx1: Int, to idx2: Int) {
        self.slots.replaceSubrange(idx1...idx2,
                                   with: self.slots[idx1...idx2].reversed())
    }
}
