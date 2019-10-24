//
//  main.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/18.
//  Copyright © 2019 AlexZHU. All rights reserved.
//

import Foundation

func main() {
    
    guard let handle = FileHandle.init(forReadingAtPath: "/Users/alexzhu/Desktop/lua-5.3.5/luac.out") else {
        fatalError("no file")
    }
    let data = handle.readDataToEndOfFile()
    
    let proto = BinaryChunk.undump(data: [UInt8](data))
    print(proto)
    
}

main()
