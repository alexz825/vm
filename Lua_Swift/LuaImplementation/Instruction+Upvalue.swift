//
//  Instruction+Upvalue.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/11.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

extension Instruction {
    
    func setTabUp(vm: LuaVM) {
        var (a, b, c) = self.ABC()
        a += 1
        vm.getRK(rk: b)
        vm.getRK(rk: c)
        
        vm.setTable(idx: luaUpvalueIndex(a))
    }
    func getTabUp(vm: LuaVM) {
        var (a, b, c) = self.ABC()
        a += 1
        b += 1

        vm.getRK(rk: c)
        vm.getTable(idx: luaUpvalueIndex(b))
        vm.replace(idx: a)
    }
    
    func getUpval(vm: LuaVM) {
        var (a, b, _) = self.ABC()
        a += 1
        b += 1
        
        vm.copy(from: luaUpvalueIndex(b), to: a)
    }
    
    func setUpval(vm: LuaVM) {
        var (a, b, _) = self.ABC()
        a += 1
        b += 1
        vm.copy(from: a, to: luaUpvalueIndex(b))
    }
    
    
}
