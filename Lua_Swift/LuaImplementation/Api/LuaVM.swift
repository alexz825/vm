//
//  LuaVM.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/1.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Cocoa
typealias LuaVM = LuaStateInstance
//struct LuaVM {
//    let state: LuaStateInstance
//    // 返回当前pc; 测试用
//    var pc: Int {
//        return self.state.pc
//    }
//    // 修改PC （用于实现跳转指令）
//    func addPC(n: Int) {
//        self.state.addPC(n: n)
//    }
//    // 取出当前指令，将PC指向下一条命令
//    func fetch() -> UInt32 {
//        return 0
//    }
//
//    // 将指定常量推入栈顶
//    func getConst(idx: Int) {
//
//    }
//
//    // 将指定常量或栈值推入栈顶
//    func getRK(rk: Int) {
//
//    }
//}
