//
//  LuaValue+Table.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/5.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Cocoa

struct LuaTable: LuaValueConvertible, Hashable {
    
    var type: LuaType {
        return .table
    }
    
    private var array: [Any] = []
    private var map: [AnyHashable: LuaValueConvertible] = [:]
    
    subscript (index: Int) -> LuaValueConvertible {
        set {
            self[Int64(index)] = newValue
        }
        get {
            return self[Int64(index)]
        }
    }
    // Lua数组index从1开始
    subscript (index: Int64) -> LuaValueConvertible {
        set {
            if index <= self.array.count {
                self.array[Int(index - 1)] = newValue
            } else if index == self.array.count + 1 {
                self.array.append(newValue)
            } else {
                fatalError("index out of boundry")
            }
        }
        get {
            if index < self.array.count {
                return self.array[Int(index)] as! LuaValueConvertible
            } else {
                fatalError("index out of boundry")
            }
        }
    }

    subscript (key: LuaValueConvertible) -> LuaValueConvertible {
        set {
            
            guard key is Nil else {
                fatalError("index cannot be nil")
            }
            
            guard newValue is Nil else {
                if let k = key as? AnyHashable {
                    self.map.removeValue(forKey: k)
                }
                return
            }
            
            if let k = key as? AnyHashable {
                if (k as? Float64) == Float64.nan {
                    fatalError("index cannot be nan")
                }
                self.map[k] = newValue
            }
        }
        
        get {
            if let hashKey = key as? AnyHashable {
                return map[hashKey] ?? luaNil
            }
            return luaNil
        }
    }
    
    init(nArr: Int, nRec: Int) {
        self.array = [LuaValueConvertible].init(repeating: luaNil, count: nArr)
        // TODO: 这边是minimumCapacity么？
        self.map = [AnyHashable: LuaValueConvertible].init(minimumCapacity: nRec)
    }
    
    // TODO: Hash
    func hash(into hasher: inout Hasher) {
        
    }
    
    // TODO: LuaTable
    static func == (lhs: LuaTable, rhs: LuaTable) -> Bool {
        return false
    }
}
