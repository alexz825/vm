//
//  Api.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/26.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

enum LuaType: Int {
    case none = -1 // Lua栈是按照索引取值，如果是一个无效索引，则就是none
    case nil_
    case boolean
    case nubmer
    case string
    case lightUserData
    case table
    case function
    case userData
    case thread
}
