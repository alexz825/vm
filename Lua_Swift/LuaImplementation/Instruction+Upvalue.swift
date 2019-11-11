//
//  Instruction+Upvalue.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/11.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

extension Instruction {
    func getTabUp(vm: LuaVM) {
        var (a, _, c) = self.ABC()
        a += 1
        vm.pushGlobalTable()
        vm.getRK(rk: c)
        vm.getTable(idx: -2)
        vm.replace(idx: a)
        vm.pop(n: 1)
    }
    
    
}
