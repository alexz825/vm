//
//  ApiAccess.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/27.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

extension LuaType {
    func name() -> String {
        let msg: String
        switch self {
        case .none:
            msg = "no value"
        case .nil_:
            msg = "nil"
        case .boolean:
            msg = "boolean"
        case .nubmer:
            msg = "number"
        case .string:
            msg = "string"
        case .table:
            msg = "table"
        case .function:
            msg = "function"
        case .thread:
            msg = "thread"
        case .lightUserData:
            msg = "light user data"
        case .userData:
            msg = "user data"
        }
        return msg
    }
}
