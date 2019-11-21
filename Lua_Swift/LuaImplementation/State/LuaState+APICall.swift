//
//  LuaState+APICall.swift
//  LuaImplementation
//
//  Created by chenmu on 2019/11/7.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

extension LuaStateInstance {
    func load(chunk: [Byte], chunkName: String, mode: String) -> Int {
        let proto = BinaryChunk.undump(data: chunk)
        var c = LuaClosure.init(proto: proto)
        if !proto.Upvalues.isEmpty {
            let env = self.registry[LUA_RIDX_GLOBALS]
            c.upvalue.append(LuaClosureUpvalue(val: env))
        }
        self.stack.push(value: c)
        return 0
    }
    
    func call(nArgs: Int, nResults: Int) {
        let val = self.stack.get(idx: -(nArgs + 1))
        guard let lua = val as? LuaClosure else {
            fatalError("not function!")
        }
        if lua.proto != nil {
            self.callLuaClosure(nArgs: nArgs, nResults: nResults, c: lua)
        } else if lua.swiftFunction != nil {
            self.callSwiftClosure(nArgs: nArgs, nResults: nResults, c: lua)
        }
        
    }
    
    func callLuaClosure(nArgs: Int, nResults: Int, c: LuaClosure) {
        let nRegs = Int(c.proto.MaxStackSize)
        let nParams = Int(c.proto.NumParams)
        let isVarags = c.proto.IsVararg == 1
        // 新建stack
        let newStack = LuaStack.init(size: nRegs + LUA_MINSTACK, state: self)
        newStack.closure = c
        // stack push 进参数
        let funcAndArgs = self.stack.popN(n: nArgs + 1)
        newStack.pushN(vals: [LuaValueConvertible](funcAndArgs[1..<funcAndArgs.count]), n: nParams)
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
    
    func callSwiftClosure(nArgs: Int, nResults: Int, c: LuaClosure) {
        let newStack = LuaStack.init(size: nArgs + 20, state: self)
        newStack.closure = c
        
        let args = self.stack.popN(n: nArgs)
        newStack.pushN(vals: args, n: nArgs)
        self.stack.pop()
        
        self.pushLuaStack(stack: newStack)
        let r = c.swiftFunction(self)
        self.popLuaStack()
        
        if nResults != 0 {
            let results = newStack.popN(n: r)
            self.stack.check(n: results.count)
            self.stack.pushN(vals: results, n: nResults)
        }
    }
}
