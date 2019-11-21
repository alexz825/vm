//
//  Instruction+Function.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/7.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

extension Instruction {
    func closure(vm: LuaVM) {
        var (a, bx) = self.ABx()
        a += 1
        vm.load(proto: bx)
        vm.replace(idx: a)
    }
    
    func call(vm: LuaVM) {
        var (a, b, c) = self.ABC()
        a += 1
        
        let nArgs = pushFuncAndArgs(a: a, b: b, vm: vm)
        vm.call(nArgs: nArgs, nResults: c-1)
        popResults(a: a, resultCount: c, vm: vm)
    }
    
    private func pushFuncAndArgs(a: Int, b: Int, vm: LuaVM) -> Int {
        if b >= 1 {
            vm.checkStack(n: b)
            for i in a..<(a+b) {
                vm.push(value: i)
            }
            return b - 1
        } else {
            fixStack(a: a, vm: vm)
            return vm.getTop() - vm.registerCount - 1
        }
    }
    
    private func popResults(a: Int, resultCount: Int, vm: LuaVM) {
        if resultCount == 1 { // no resluts
        } else if resultCount > 1 {
            var i = (a+resultCount-2)
            while i >= a {
                vm.replace(idx: i)
                i -= 1
            }
        } else {
            vm.checkStack(n: 1)
            vm.pushInteger(n: Int64(a))
        }
    }
    
    private func fixStack(a: Int, vm: LuaVM) {
        let x = Int(vm.toInteger(idx: -1))
        vm.pop(n: 1)
        vm.checkStack(n: x - a)
        for i in a..<x {
            vm.push(value: i)
        }
        vm.rotate(idx: vm.registerCount+1, n: x-a)
    }
    
    func return_(vm: LuaVM) {
        var (a, b, _) = self.ABC()
        a += 1
        if b == 1 { // no return value
        } else if b > 1 { // b - 1 return values
            vm.checkStack(n: b - 1)
            for i in a...(a+b-2) {
                vm.push(value: i)
            }
        } else {
            fixStack(a: a, vm: vm)
        }
    }
    
    func vararg(vm: LuaVM) {
        var (a, b, _) = self.ABC()
        a += 1
        if b != 1 {
            vm.load(nVararg: b - 1)
            popResults(a: a, resultCount: b, vm: vm)
        }
    }
    
    func tailCall(vm: LuaVM) {
        var (a, b, _) = self.ABC()
        a += 1
        let c = 0
        
        let nArgs = pushFuncAndArgs(a: a, b: b, vm: vm)
        vm.call(nArgs: nArgs, nResults: c - 1)
        popResults(a: a, resultCount: c, vm: vm)
    }
    
    func self_(vm: LuaVM) {
        var (a, b, c) = self.ABC()
        a += 1
        b += 1
        vm.copy(from: b, to: a + 1)
        vm.getRK(rk: c)
        vm.getTable(idx: b)
        vm.replace(idx: a)
    }
    
}
