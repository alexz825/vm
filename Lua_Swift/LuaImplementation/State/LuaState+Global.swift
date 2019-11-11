//
//  LuaState+Global.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/11.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Cocoa

extension LuaStateInstance {
    func pushGlobalTable() {
        let global = self.registry[LUA_RIDX_GLOBALS]
        self.stack.push(value: global)
    }
    
    func getGlobal(name: String) -> LuaType {
        let val = self.registry[name]
        return self.getTable(t: val, k: name)
    }
    func setGlobal(name: String) {
        guard var t = self.registry[LUA_RIDX_GLOBALS] as? LuaTable else {
            fatalError("not global table")
        }
        let v = self.stack.pop()
//        self.setTable(t: t, k: name, v: v, tableIndex: self.stack.top)
        t[name] = v
        self.registry[LUA_RIDX_GLOBALS] = t
    }
    
    func register(name: String, f: @escaping SwiftFunction) {
        self.pushSwiftFunction(f: f)
        self.setGlobal(name: name)
    }
}
