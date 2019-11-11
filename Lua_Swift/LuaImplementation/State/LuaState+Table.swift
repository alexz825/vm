//
//  LuaState+Table.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/6.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Cocoa

extension LuaStateInstance {
    func createTable(nArr: Int, nRec: Int) {
        let t = LuaTable.init(nArr: nArr, nRec: nRec)
        self.stack.push(value: t)
    }
    
    func newTable() {
        self.createTable(nArr: 0, nRec: 0)
    }
    
    @discardableResult
    func getTable(idx: Int) -> LuaType {
        let t = self.stack.get(idx: idx)
        let k = self.stack.pop()
        return self.getTable(t: t, k: k)
    }
    
    func getTable(t: LuaValueConvertible, k: LuaValueConvertible) -> LuaType {
        guard let table = t as?  LuaTable else {
            fatalError("not a table")
        }
        let v = table[k]
        self.stack.push(value: v)
        return v.type
    }
    
    func getField(idx: Int, k: String) -> LuaType {
//        let t = self.stack.get(idx: idx)
//        return self.getTable(t: t, k: k)
        self.pushString(s: k)
        return self.getTable(idx: idx)
    }
    
    func getI(idx: Int, i: Int64) -> LuaType {
        let t = self.stack.get(idx: idx)
        return self.getTable(t: t, k: i)
    }
    
    func setTable(idx: Int) {
        let t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        let k = self.stack.pop()
        self.setTable(t: t, k: k, v: v, tableIndex: idx)
    }
    
    func setTable(t: LuaValueConvertible, k: LuaValueConvertible, v: LuaValueConvertible, tableIndex: Int) {
        guard var table = t as? LuaTable else {
            fatalError("not a table!")
        }
        table[k] = v
        self.stack.set(idx: tableIndex, val: table)
    }
    
    func setField(idx: Int, k: String) {
        let t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        self.setTable(t: t, k: k, v: v, tableIndex: idx)
    }
    
    func setI(idx: Int, n: Int64) {
        let t = self.stack.get(idx: idx)
        let v = self.stack.pop()
        self.setTable(t: t, k: n, v: v, tableIndex: idx)
    }
}
