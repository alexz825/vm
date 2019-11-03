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

protocol LuaValueType {
    var type: LuaType {get}
}

extension LuaValueType {
    func convertToFloat() -> Float64? {
        if let v = self as? Arithable {
            return try? v.float()
        }
        return nil
    }
}

extension String: LuaValueType, Arithable {
    var type: LuaType {
        return .string
    }
}

extension UInt64: LuaValueType, Arithable {
    var type: LuaType {
        return .nubmer
    }
}

extension Int64: LuaValueType, Arithable {
    var type: LuaType {
        return .nubmer
    }
}
extension Float64: LuaValueType, Arithable {
    var type: LuaType {
        return .nubmer
    }
}
extension Bool: LuaValueType {
    var type: LuaType {
        return .boolean
    }
}

struct Nil: CustomStringConvertible, LuaValueType {
    var type: LuaType {
        return .nil_
    }
    
    var description: String {
        return "nil"
    }
}

var luaNil: Nil = {
    return Nil()
}()

