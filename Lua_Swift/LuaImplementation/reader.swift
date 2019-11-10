import Foundation

struct Reader {
    var data: Bytes
    
    init(data: Bytes) {
        self.data = data
    }

    func readByte() -> Byte {
        return self.data.export8Bits()
    }

    /// 小端读取int32
    func readUInt32() -> UInt32 {
        let uint32 = self.data.export32Bits()
        return UInt32.init(littleEndian: uint32)
    }
    /// 小端读取int64
    func readUInt64() -> UInt64 {
        return UInt64.init(littleEndian: self.data.export64Bits())
    }
    
    /// 读取一个Lua Integer占8个字节
    func readLuaInteger() -> UInt64 {
        return self.data.export64Bits()
    }
    /// 读取一个Lua Number
    func readLuaNumber() -> Float64 {
        return Float64(bitPattern: self.readUInt64())
    }
    /// 读取一个Lua String
    func readString() -> String {
        var size = UInt64.init(self.readByte())
        if size == 0 { // NULL
            return ""
        }
        if size == 0xff { // 长字符串
            size = self.readUInt64()
        }
        let bytes = self.data.exportBytes(count: Int(size - 1))
        guard let string = String.init(bytes: bytes, encoding: .utf8) else {
            fatalError("bytes cannot convert to string")
        }
        return string
    }
    
    func checkHeader() {
        let defaultHeader = Header()
        if self.data.exportBytes(count: 4) != defaultHeader.signature {
            fatalError("not a precomiled chunk!")
        }
        if self.data.export8Bits() != defaultHeader.version {
            fatalError("version mismatch!")
        }
        if self.data.export8Bits() != defaultHeader.format {
            fatalError("format mismatch!")
        }
        if self.data.exportBytes(count: 6) != defaultHeader.luacData {
            fatalError("corrupted!")
        }
        if self.data.export8Bits() != defaultHeader.cintSize {
            fatalError("int size mismatch!")
        }
        if self.data.export8Bits() != defaultHeader.sizeSize {
            fatalError("size_t size mismatch!")
        }
        if self.data.export8Bits() != defaultHeader.instructionSize {
            fatalError("instruction size mismatch!")
        }
        if self.data.export8Bits() != defaultHeader.luaIntergerSize {
            fatalError("lua_integer size mismatch!")
        }
        if self.data.export8Bits() != defaultHeader.luaNumberSize {
            fatalError("lua_integer size mismatch!")
        }

        if self.readLuaInteger() != defaultHeader.luacInt {
            fatalError("endianness mismatch!")
        }
        if self.readLuaNumber() != defaultHeader.luacNum {
            fatalError("format mismatch mismatch!")
        }
    }
    
    func readProto(parentSource: String) -> Prototype {
        var source = self.readString()
        if source == "" { source = parentSource }
        return Prototype(Source: source,
                         LineDefined: self.readUInt32(),
                         LastLineDefined: self.readUInt32(),
                         NumParams: self.readByte(),
                         IsVararg: self.readByte(),
                         MaxStackSize: self.readByte(),
                         Code: self.readCode(),
                         Constants: self.readConstants(),
                         Upvalues: self.readUpvalues(),
                         Protos: self.readProtos(parentSource: source),
                         LineInfo: self.readLineInfo(),
                         LocVars: self.readLocVars(),
                         UpvalueNames: self.readUpvalueNames())
    }
    // 读取指令表
    func readCode() -> [UInt32] {
        return (UInt32(0)..<self.readUInt32()).map({_ in self.readUInt32()})
    }
    // 读取常量表
    func readConstants() -> [Constant] {
        return (UInt32(0)..<self.readUInt32()).map({ _ -> Constant in
            return self.readConstant()
        })
    }
    func readConstant() -> Constant {
        guard let tag = Constant.Tag.init(rawValue: self.readByte()) else {
            fatalError("cannot read Constant Tag")
        }
        let value: Any
        switch tag {
        case .nil_:
             value = luaNil
        case .boolean:
            value = self.readByte() != 0
        case .integer:
            value = self.readLuaInteger()
        case .number:
            value = self.readLuaNumber()
        case .shortStr:
            value = self.readString()
        case .longStr:
            value = self.readString()
        }
        return Constant(type: tag, value: value)
    }
    
    func readUpvalues() -> [Upvalue] {
        return (UInt32(0)..<self.readUInt32()).map { (i) -> Upvalue in
            return Upvalue(Instack: self.readByte(), Idx: self.readByte())
        }
    }
    
    func readProtos(parentSource: String) -> [Prototype] {
        return (UInt32(0)..<self.readUInt32()).map({ (_) -> Prototype in
            return self.readProto(parentSource: parentSource)
        })
    }
    
    func readLineInfo() -> [UInt32] {
        return (UInt32(0)..<self.readUInt32()).map({ _ in self.readUInt32()})
    }
    
    func readLocVars() -> [LocVar] {
        return (UInt32(0)..<self.readUInt32()).map({ _ in LocVar.init(varName: self.readString(),
                                                                      startPC: self.readUInt32(),
                                                                      endPC: self.readUInt32())})
    }
    
    func readUpvalueNames() -> [String] {
        return (UInt32(0)..<self.readUInt32()).map({ _ in self.readString()})
    }
}

