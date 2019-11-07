//
//  LuaClosure.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/7.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Cocoa

struct LuaClosure: LuaValueConvertible {
    let proto: Prototype
    var type: LuaType {
        return .function
    }
}
