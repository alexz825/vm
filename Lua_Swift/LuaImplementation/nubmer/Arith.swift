//
//  Arith.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/29.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Cocoa

protocol Arithable {}

extension Arithable {
    // Lua运算符会在适当的情况下对操作数进行自动类型转换
    // 1. 算术运算符， 除法和乘方：整数，字符串都转成float进行运算，其他运算符：如果操作数全部是整数，则进行整数运算，结果也是整数，否则都换成浮点数进行运算
    // 2. 按位运算符：
    //      如果操作数都是整数，无需转换；
    //      如果操作数是浮点数，但实际是整数，且没有超过整数取值范围，则转换为整数；如果
    //      如果操作数是字符串，且可以解析为整数值，则解析成整数
    //      如果操作数是字符串，无法转换成整数值，可以转换成浮点数，且浮点数可以按上面的规则转换成整数，则解析为浮点数再转换成整数
    // 3. 字符串拼接： 都转换成字符串
    
    // 转成Float64
    func float() throws -> Float64 {
        if let x = self as? Int64 {
            return Float64(x)
        }
        if let x = self as? Float64 {
            return x
        }
        if let x = self as? String, let y = Float64(x) {
            return y
        }
        throw LuaError.arithError(msg: "\(self) is not a Float64 value")
    }
    
    // Int或者小数点后面只有0，转成Int64
    func int() throws -> Int64 {
        if let x = self as? Int64 {
            return x
        }
        if let x = try? self.float() {
            if x.truncatingRemainder(dividingBy: 1) == 0 {
                return Int64(x)
            }
        }
        throw LuaError.arithError(msg: "\(self) is not a Int value")
    }
}

enum ArithOperator {
    case add // +
    case sub // -
    case mul // *
    case mod // %
    case pow // ^
    case div // /
    case iDiv // //
    case bAnd // &
    case bOr // |
    case bXor // ~
    case shl // <<
    case shr // >>
    case unm // - (unary minus)
    case bNot // ~
    
    func action(lhs: LuaValueType, rhs: LuaValueType = luaNil) throws -> LuaValueType {
        switch self {
        case .add:
            return try self.floatArith(lhs: lhs, rhs: rhs, operatorFunc: +)
        case .sub:
            return try self.floatArith(lhs: lhs, rhs: rhs, operatorFunc: -)
        case .mul:
            return try self.floatArith(lhs: lhs, rhs: rhs, operatorFunc: *)
        case .div:
            return try self.floatArith(lhs: lhs, rhs: rhs, operatorFunc: /)
        case .iDiv:
            return try self.intArith(lhs: lhs, rhs: rhs, operatorFunc: %)
        case .bAnd:
            return try self.intArith(lhs: lhs, rhs: rhs, operatorFunc: &)
        case .bOr:
            return try self.intArith(lhs: lhs, rhs: rhs, operatorFunc: |)
        case .bXor:
            return try self.intArith(lhs: lhs, rhs: rhs, operatorFunc: ^)
        case .shl:
            return try self.intArith(lhs: lhs, rhs: rhs, operatorFunc: <<)
        case .shr:
            return try self.intArith(lhs: lhs, rhs: rhs, operatorFunc: >>)
        case .unm:
            return try self.binaryArith(v: lhs, operatorFun: -)
        case .bNot:
            return try self.binaryArith(v: lhs, operatorFun: ~)
        default:
            return 1
        }
    }
    
    private func floatArith(lhs: LuaValueType, rhs: LuaValueType, operatorFunc: (_ lhs: Float64, _ rhs: Float64) -> Float64) throws -> LuaValueType {
        guard let v1 = lhs as? Arithable else {
            throw LuaError.arithError(msg: "\(rhs) is not arithable")
        }
        guard let v2 = rhs as? Arithable else {
            throw LuaError.arithError(msg: "\(rhs) is not arithable")
        }
        if let v1 = try? v1.float(), let v2 = try? v2.float() {
            return operatorFunc(v1, v2)
        }
        fatalError("arith error")
    }
    
    private func intArith(lhs: LuaValueType, rhs: LuaValueType, operatorFunc: (_ lhs: Int64, _ rhs: Int64) -> Int64) throws -> LuaValueType {
        guard let v1 = rhs as? Arithable else {
            throw LuaError.arithError(msg: "\(rhs) is not arithable")
        }
        guard let v2 = rhs as? Arithable else {
            throw LuaError.arithError(msg: "\(rhs) is not arithable")
        }
        return operatorFunc(try v1.int(), try v2.int())
    }
    
    private func binaryArith(lhs: LuaValueType, rhs: LuaValueType, operatorFun: (_ lhs: Int64, _ rhs: Int64) -> Int64) throws -> LuaValueType {
        return try self.intArith(lhs: lhs, rhs: rhs, operatorFunc: operatorFun)
//        guard let v1 = rhs as? Arithable else {
//            throw LuaError.arithError(msg: "\(rhs) is not arithable")
//        }
//        guard let v2 = rhs as? Arithable else {
//            throw LuaError.arithError(msg: "\(rhs) is not arithable")
//        }
//        return operatorFun(try v1.int(), try v2.int())
    }
    
    private func binaryArith(v: LuaValueType, operatorFun: (_ lhs: Int64) -> Int64) throws -> LuaValueType {
        guard let value = v as? Arithable else {
            throw LuaError.arithError(msg: "\(v) is not arithable")
        }
        return operatorFun(try value.int())
    }
}

enum CompareOperator {
    case eq // ==
    case lt // <
    case le // <=
    
    func action(v1: LuaValueType, v2: LuaValueType) -> Bool {
        switch (v1.type, v2.type) {
        case (.nil_, .nil_):
            switch self {
            case .eq:
                return true
            default:
                break
            }
        case (.boolean, .boolean):
            return (v1 as! Bool) == (v2 as! Bool)
        case (.nubmer, .nubmer):
            let v1 = (try! (v1 as! Arithable).float())
            let v2 = (try! (v2 as! Arithable).float())
            switch self {
            case .eq:
                return v1 == v2
            case .lt:
                return v1 < v2
            case .le:
                return v1 <= v2
            }
        case (.string, .string):
            switch self {
            case .eq:
                return (v1 as! String) == (v2 as! String)
            case .le:
                return (v1 as! String) <= (v2 as! String)
            case .lt:
                return (v1 as! String) < (v2 as! String)
            }
        default:
            break
        }
        return false
//        fatalError("comparison error")
    }
}
