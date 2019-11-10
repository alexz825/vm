
struct Header {
    // 魔数 四个字节分别是 ESC、L、u、a，0x1B4C7561
    let signature: [UInt8] = Array.init("\u{1b}Lua".utf8) //[0x10, 0xB4, 0x75, 0x61]
    // 版本号，加载文件时，判断版本是否一致，大版本号*16+小版本号，不管发布号
    let version: Byte = 0x53
    // 加载时会判断是否相同，不相同拒绝加载，Lua官方实现是0x00
    let format: Byte = 0x00
    // 6个字节，前两个字节是0x1993(1.0发布的年份)，后四个字节：0x0D(回车),0x0A(换行),0x1A(替换)，
    // 和另外一个换行符,合起来就是0x19930D0A1A0A，也是用于判断校验。
    let luacData: [Byte] = [0x19, 0x93, 0x0D, 0x0A, 0x1A, 0x0A]
    // 以下五个是加载的时候会判断是否与期待值是否一致，不一致，拒绝加载
    // 记录cint类型占用的字节数
    let cintSize: Byte = 4
    // 记录size_t类型占用的字节数
    let sizeSize: Byte = 8
    // 记录 Lua虚拟机指令 占用的字节数
    let instructionSize: Byte = 4
    // 记录Lua整数 占用的字节
    let luaIntergerSize: Byte = 8
    // 记录Lua浮点数占用的字节
    let luaNumberSize: Byte = 8
    // 0x5678 代表当前机器上Lua整数占8个字节
    let luacInt: UInt64 = 0x5678
    // 370.5 0x7728
    let luacNum: Float64 = 370.5
}

struct Upvalue {
    let Instack: Byte
    let Idx: Byte
}

struct LocVar {
    let varName: String
    let startPC: UInt32
    let endPC: UInt32
}

struct Constant: CustomStringConvertible {
    
    enum Tag: Byte {
        case nil_ = 0x00
        case boolean = 0x01
        case number = 0x03
        case integer = 0x13
        case shortStr = 0x04
        case longStr = 0x14
    }
    
    let type: Tag
    let value: Any
    
    var description: String {
        if type == .nil_ {
            return  "nil"
        }
        return "\(value)"
    }
}

struct Prototype {
    // 源文件名，记录哪个文件编译出来的，为避免重复，只有在主函数原型里才有值（其他嵌套函数原型里为空值）
    // 以@开头说明这个二进制chunk是从Lua源文件编译而来的，以=开头说明是从标准输入编译而来的，没有=说明是从程序的字符串编译而来的，来源存放的是字符串
    let Source: String
    // 起始行号
    let LineDefined: UInt32
    // 结束行号
    let LastLineDefined: UInt32
    // 固定参数个数
    let NumParams: Byte
    // 是否是Vararg，0代表否，1代表是
    let IsVararg: Byte
    // 寄存器数量
    let MaxStackSize: Byte
    // 指令表，占4个字节
    let Code: [UInt32]
    // 常量表，用于春芳Lua代码里出现的字面量，包括Nil，布尔值，整数，浮点数和字符串五种
    // 每个常量以1字节tag开头，用来表示后续存储的是哪种类型的常量值
    // 常用0x00 nil 不存储，0x01 bool 字节（0，1），0x03 number lua浮点，0x13 integer lua整数，0x04 string 短字符串，0x14 string 长字符串
    let Constants: [Constant]
    // TODO: 第十章时补充
    let Upvalues: [Upvalue]
    // 子函数原型表
    let Protos: [Prototype]
    // 行号，与指令表中的指令一一对应
    let LineInfo: [UInt32]
    // 局部变量表：用于记录局部变量名，表中每个元素都包含变量名（按字符串类型存储）和起始指令列表（按cInt类型存储）
    let LocVars: [LocVar]
    // Upvalue名列表
    let UpvalueNames: [String]
}

struct BinaryChunk {
    let header: Header
    let sizeUpValue: Int8
    let mainFunc: Prototype
    
    // TODO: 未完成
    static func undump(data: [UInt8]) -> Prototype {
        
        let reader = Reader.init(data: Bytes.init(existingBytes: data))
        reader.checkHeader() // 校验头部
        _ = reader.readByte() // 跳过Upvalue
        return  reader.readProto(parentSource: "")
    }
    
}

