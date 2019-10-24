//
//  main.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/18.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Foundation

func main() {
    guard let handle = FileHandle.init(forReadingAtPath: "/Users/chenmu/Desktop/LuaSwift/test/luac.out") else {
        fatalError("no file")
    }
    let data = handle.readDataToEndOfFile()
    
    let proto = BinaryChunk.undump(data: [UInt8](data))
//    print(proto)
    list(proto)
    
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
    if proto.IsVarary > 0 { varargFlag = "+" }
    
    print("\(funcType) <\(proto.Source): \(proto.LineDefined) \(proto.LastLineDefined), \(proto.Code.count)>")
    print("\(proto.NumParams) \(varargFlag) params,  \(proto.MaxStackSize) slots, \(proto.Upvalues.count) upvalues")
    print("\(proto.LocVars.count) locals, \(proto.Constants.count) constans, \(proto.Protos.count) functions")
}

func printCode(_ proto: Prototype) {
    for (index, code) in proto.Code.enumerated() {
        var line = "-"
        if proto.LineInfo.count > 0 {
            line = "\(proto.LineInfo[index])"
        }
        
        print("\t \(index + 1) \t [\(line)] \t 0x\(code)")
    }
}

func printDetail(_ proto: Prototype) {
    print("constants (\(proto.Constants.count):)")
    for (i, cons) in proto.Constants.enumerated() {
        print("\t\(i+1)\t \(String(describing: cons))")
    }
}

main()
