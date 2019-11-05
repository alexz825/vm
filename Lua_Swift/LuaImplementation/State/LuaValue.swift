//
//  LuaValue.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/1.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Cocoa

enum LuaError: Error {
    case arithError(msg: String)
}

protocol LuaValueConvertible {
    var type: LuaType {get}
}

extension LuaValueConvertible {
    func convertToFloat() -> Float64? {
        if let v = self as? Arithable {
            return try? v.float()
        }
        return nil
    }
}

extension String: LuaValueConvertible, Arithable {
    var type: LuaType {
        return .string
    }
}

extension UInt64: LuaValueConvertible, Arithable {
    var type: LuaType {
        return .nubmer
    }
}

extension Int64: LuaValueConvertible, Arithable {
    var type: LuaType {
        return .nubmer
    }
}
extension Float64: LuaValueConvertible, Arithable {
    var type: LuaType {
        return .nubmer
    }
}
extension Bool: LuaValueConvertible {
    var type: LuaType {
        return .boolean
    }
}

struct Nil: CustomStringConvertible, LuaValueConvertible, Equatable {
    var type: LuaType {
        return .nil_
    }
    
    var description: String {
        return "nil"
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return true
    }
}

var luaNil: Nil {
    return Nil()
}

