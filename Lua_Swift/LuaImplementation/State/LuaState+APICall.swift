//
//  LuaState+APICall.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/7.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Cocoa

extension LuaStateInstance {
    func load(chunk: [Byte], chunkName: String, mode: String) -> Int {
        let proto = BinaryChunk.undump(data: chunk)
        let c = LuaClosure.init(proto: proto)
        self.stack.push(value: c)
        return 0
    }
    
    func call(nArgs: Int, nResults: Int) {
        let val = self.stack.get(idx: -(nArgs + 1))
        guard let function = val as? LuaClosure else {
            fatalError("not function!")
        }
        print("call \(function.proto.Source) <\(function.proto.LineDefined), \(function.proto.LastLineDefined)>")
        self.callLuaClosure(nArgs: nArgs, nResults: nResults, c: function)
    }
    
    func callLuaClosure(nArgs: Int, nResults: Int, c: LuaClosure) {
        let nRegs = Int(c.proto.MaxStackSize)
        let nParams = Int(c.proto.NumParams)
        let isVarags = c.proto.IsVarary == 1
        // 新建stack
        let newStack = LuaStack.init(size: nRegs + 20)
        newStack.closure = c
        // stack push 进参数
        let funcAndArgs = self.stack.popN(n: nArgs + 1)
        newStack.pushN(vals: funcAndArgs, n: nParams)
        newStack.top = nRegs
        if nArgs > nParams && isVarags {
            newStack.varargs = [LuaValueConvertible](funcAndArgs[nParams+1..<funcAndArgs.count])
        }
        
        self.pushLuaStack(stack: newStack)
        self.runLuaClosure()
        self.popLuaStack()
        
        if nResults != 0 {
            let results = newStack.popN(n: newStack.top - nRegs)
            self.stack.check(n: results.count)
            self.stack.pushN(vals: results, n: nResults)
        }
    }
    
    func runLuaClosure() {
        while true {
            let inst = Instruction(self.fetch())
            inst.excute(vm: self)
            if inst.opCode.opCode == .return_ {
                break
            }
        }
    }
}
