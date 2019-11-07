//
//  LuaValue+Table.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/5.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Cocoa
// TODO: 需要添加动态扩展数组内存，将map中能够移动到数组的值移过去
struct LuaTable: LuaValueConvertible, Hashable {
    
    var type: LuaType {
        return .table
    }
    
    private var array: [Any] = []
    private var map: [AnyHashable: LuaValueConvertible] = [:]
    
    subscript (index: Int) -> LuaValueConvertible {
        set {
            if index <= self.array.count {
                self.array[index - 1] = newValue
                if self.array.last is Nil {
                    self.array.removeLast()
                }
            } else if index == self.array.count + 1 {
                if !(newValue is Nil) {
                    self.array.append(newValue)
                    var arrLen = self.array.count
                    while self.map.keys.contains(arrLen) {
                        self.array.append(self.map[arrLen]!)
                        arrLen += 1
                        self.map.removeValue(forKey: arrLen)
                    }
                }
            } else {
                self.map[index] = newValue
            }
        }
        get {
            if index <= self.array.count {
                return self.array[index - 1] as! LuaValueConvertible
            } else {
                return self.map[index] ?? luaNil
            }
        }
        
    }
    // Lua数组index从1开始
    subscript (index: Int64) -> LuaValueConvertible {
        set {
            self[Int(index)] = newValue
        }
        get {
            return self[Int(index)]
        }
    }
    
    subscript (index: UInt64) -> LuaValueConvertible {
        set {
            self[Int(index)] = newValue
        }
        get {
            return self[Int(index)]
        }
    }

    subscript (key: LuaValueConvertible) -> LuaValueConvertible {
        set {
            guard !(key is Nil) else {
                fatalError("index cannot be nil")
            }
            
            guard !(newValue is Nil) else {
                if let k = key as? AnyHashable {
                    self.map.removeValue(forKey: k)
                }
                return
            }
            if let intK = try? (key as? Arithable)?.int() {
                self[intK] = newValue
            }
            
            if let k = key as? AnyHashable {
                if (k as? Float64) == Float64.nan {
                    fatalError("index cannot be nan")
                }
                self.map[k] = newValue
            }
        }
        
        get {
            if let intV = try? (key as? Arithable)?.int() {
                return self[intV]
            }
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
    
    func len() -> Int {
        return self.array.count
    }
}
