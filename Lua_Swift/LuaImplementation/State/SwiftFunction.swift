//
//  SwiftFunction.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/11.
//  Copyright © 2019 AlexZHU. All rights reserved.
//


typealias SwiftFunction = (_ ls: LuaState) -> Int

func luaUpvalueIndex(_ i: Int) -> Int {
    return LUA_REGISTRYINDEX - i
}

extension LuaStateInstance {
    func pushSwiftFunction(f: @escaping SwiftFunction) {
        self.stack.push(value: LuaClosure.init(f))
    }
    
    func isSwiftFunction(idx: Int) -> Bool {
        guard let val = self.stack.get(idx: idx) as? LuaClosure else {
            return false
        }
        return val.swiftFunction != nil
    }
    
    func toSwiftFunction(idx: Int) -> SwiftFunction? {
        guard let val = self.stack.get(idx: idx) as? LuaClosure else {
            return nil
        }
        return val.swiftFunction
    }
    
    func pushSwiftClosure(f: @escaping SwiftFunction, n: Int) {
        var closure = LuaClosure.init(f)
        for i in 1...n {
            let index = n - i - 1
            var val = self.stack.pop()
            closure.upvalue[index] = LuaClosureUpvalue(val: val)
        }
        self.stack.push(value: closure)
    }
    
}
