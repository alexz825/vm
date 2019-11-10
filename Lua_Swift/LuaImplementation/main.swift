//
//  main.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/18.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Foundation

func main() {
    let path = "/Users/alexzhu/Desktop/LuaSwift/test/luac.out"
    guard let handle = FileHandle.init(forReadingAtPath: path) else {
        fatalError("no file")
    }
    let data = handle.readDataToEndOfFile()

//    let proto = BinaryChunk.undump(data: [UInt8](data))
//    printDetail(proto)
//    luaMain(proto: proto)
    let luaState = LuaStateInstance.init()
    let _ = luaState.load(chunk: [UInt8](data),
                          chunkName: path,
                          mode: "b")
    luaState.call(nArgs: 0, nResults: 0)
}

func luaMain(proto: Prototype) {
    let nRegs = Int(proto.MaxStackSize)
    let luaState = LuaStateInstance.init(size: nRegs + 8)
    luaState.setTop(idx: nRegs)
    while true {
        let pc = luaState.pc
        let inst = Instruction(luaState.fetch())
        if inst.opCode.opCode != .return_ {
            inst.excute(vm: luaState)
            print("[\(pc + 1)] \(inst.opName())", terminator: "  ")
            printStack(ls: luaState)
        } else {
            break
        }
    }
}

func testArith() {
//    let ls = LuaStateInstance()
//    ls.pushInteger(n: 1)
//    ls.pushString(s: "2.0")
//    ls.pushString(s: "3.0")
//    ls.pushNumber(f: 4.0)
//    printStack(ls: ls)
//
//    ls.arith(op: .add)
//    printStack(ls: ls)
//    ls.arith(op: .bNot)
//    printStack(ls: ls)
//
//    ls.len(idx: 2)
//    printStack(ls: ls)
//    ls.concat(n: 3)
//    printStack(ls: ls)
//    ls.pushBoolean(b: ls.compare(idx1: 1, idx2: 2, op: .eq))
//    printStack(ls: ls)
}

func list(_ proto: Prototype) {
    print("🇨🇳")
    printHeader(proto)
    printCode(proto)
    printDetail(proto)
    for p in proto.Protos {
        list(p)
    }
}

func printHeader(_ proto: Prototype) {
    var funcType = "main"
    if proto.LineDefined > 0 {
        funcType = "function"
    }
    var varargFlag = ""
    if proto.IsVararg > 0 { varargFlag = "+" }
    
    print("\(funcType) <\(proto.Source): \(proto.LineDefined) \(proto.LastLineDefined), \(proto.Code.count)>")
    print("\(proto.NumParams) \(varargFlag) params,  \(proto.MaxStackSize) slots, \(proto.Upvalues.count) upvalues")
    print("\(proto.LocVars.count) locals, \(proto.Constants.count) constans, \(proto.Protos.count) functions")
}

func printCode(_ proto: Prototype) {
    
    func printOperands(inst: Instruction) {
        var string = ""
        switch inst.opMode() {
        case .iABC:
            let (a, b, c) = inst.ABC()
            string += "\(a)"
            if inst.bMode() != .n {
                if b > 0xff {
                    string += " \(-1 - b & 0xff)"
                } else {
                    string += " \(b)"
                }
            }
            if inst.cMode() != .n {
                if c>0xff {
                    string += " \(-1 - c & 0xff)"
                } else {
                    string += " \(c)"
                }
            }
        case .iABx:
            let (a, bx) = inst.ABx()
            string += "\(a)"
            if inst.bMode() == .k {
                string += " \(-1-bx)"
            } else if inst.bMode() == .u {
                string += " \(bx)"
            }
        case .iAsBx:
            let (a, sBx) = inst.AsBx()
            string += "\(a) \(sBx)"
        case .iAx:
            let ax = inst.Ax()
            string += "\(-1-ax)"
        }
        print(string)
    }
    
    for (index, code) in proto.Code.enumerated() {
        var line = "-"
        if proto.LineInfo.count > 0 {
            line = "\(proto.LineInfo[index])"
        }
        
        let inst = Instruction(code)
        print("\t \(index + 1) \t [\(line)] \t\(inst.opName())", separator: " ", terminator: " ")
        printOperands(inst: inst)
    }
}

func printDetail(_ proto: Prototype) {
    print("constants (\(proto.Constants.count):)")
    for (i, cons) in proto.Constants.enumerated() {
        print("\t\(i+1)\t \(String(describing: cons))")
    }
    
    print("locals \(proto.LocVars.count)")
    for (_, locvar) in proto.LocVars.enumerated() {
        print("\t \(locvar.varName) \t \(locvar.startPC + 1) \t \(locvar.endPC+1)")
    }
    
    func upvalName(prototype: Prototype, index: Int) -> String {
        // TODO: 简化
        if proto.UpvalueNames.count > 0 {
            return proto.UpvalueNames[index]
        }
        return "-"
    }
    
    print("upvalues \(proto.Upvalues.count)")
    for (index, upvalue) in proto.Upvalues.enumerated() {
        print("\t \(upvalName(prototype: proto, index: index)) \t \(upvalue.Instack) \t \(upvalue.Idx)")
    }
}

func testStack() {
//    let state = LuaStateInstance.init()
//    state.pushBoolean(b: true)
//    printStack(ls: state)
//    state.pushInteger(n: 10)
//    printStack(ls: state)
//    state.pushNil()
//    printStack(ls: state)
//    state.pushString(s: "hello")
//    printStack(ls: state)
//    state.push(value: -4)
//    printStack(ls: state)
//    state.replace(idx: 3)
//    printStack(ls: state)
//    state.setTop(idx: 6)
//    printStack(ls: state)
//    state.remove(idx: -3)
//    printStack(ls: state)
//    state.setTop(idx: -5)
//    printStack(ls: state)
}

func printStack(ls: LuaStateInstance) {
    let top = ls.getTop()
    
    for i in 1...top {
        let valueType = ls.type(idx: i)
        
        switch valueType {
        case .boolean:
            print("[\(ls.toBoolean(idx: i))]", separator: "", terminator: " ")
        case .nubmer:
            print("[\(ls.toNumber(idx: i))]", separator: "", terminator: " ")
        case .string:
            print("[\(ls.toString(idx: i))]", separator: "", terminator: " ")
        default:
            print("[\(ls.typeName(tp: valueType))]", separator: "", terminator: " ")
        }
    }
    print()
}

main()
