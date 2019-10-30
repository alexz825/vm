//
//  State.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/27.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

protocol LuaState {
    func getTop() -> Int
    func absIdx(idx: Int) -> Int
    func checkStack(n: Int) -> Bool
    func pop(n: Int)
    func copy(from idx1: Int, to idx2: Int)
    func push(value idx: Int)
    func replace(idx: Int)
    func insert(idx: Int)
    func remove(idx: Int)
    func rotate(idx: Int, n: Int)
    func setTop(idx: Int)
    // access functions (stack -> swift
    func typeName(tp: LuaType) -> String
    func type(idx: Int) -> LuaType
    func isNone(idx: Int) -> Bool
    func isNil(idx: Int) -> Bool
    func isNoneOrNil(idx: Int) -> Bool
    func isBoolean(idx: Int) -> Bool
    func isInteger(idx: Int) -> Bool
    func isNumber(idx: Int) -> Bool
    func isString(idx: Int) -> Bool
    func toBoolean(idx: Int) -> Bool
    func toInteger(idx: Int) -> Int64
    func toIntegerX(idx: Int) -> (Int64, Bool)
    func toNumber(idx: Int) -> Float64
    func toNumberX(idx: Int) -> (Float64, Bool)
    func toString(idx: Int) -> String
    func toStringX(idx: Int) -> (String, Bool)
    
    // push functions (swift -> stack)
    func pushNil()
    func pushBoolean(b: Bool)
    func pushInteger(n: Int64)
    func pushNumber(f: Float64)
    func pushString(s: String)
}
