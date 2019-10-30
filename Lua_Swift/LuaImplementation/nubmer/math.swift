//
//  math.swift
//  LuaImplementation
//
//  Created by AlexZHU on 2019/10/28.
//  Copyright © 2019 AlexZHU. All rights reserved.
//
import Cocoa
func iFloorDiv(a: Int64, b: Int64) -> Int64 {
    if a > 0 && b > 0 || a < 0 && b < 0 || a % b == 0 {
        return a / b
    } else {
        return a / b - 1
    }
}

func fFloorDiv(a: Float64, b: Float64) -> Float64 {
    return floor(Double(a/b))
}

func iMod(a: Int64, b: Int64) -> Int64 {
    return a - iFloorDiv(a: a, b: b) * b
}

func fMod(a: Float64, b: Float64) -> Float64 {
    return a - floor(a/b) * b
}

func shiftLeft(a: Int64, n: Int64) -> Int64 {
    if n >= 0 {
        return a << UInt64(n)
    } else {
        return shiftRight(a: a,n: -n)
    }
}

func shiftRight(a: Int64, n: Int64) -> Int64 {
    // 右移运算符是无符号右移，空出来的比特只是简单地补0。
    if n >= 0 {
        return Int64(UInt64(a) >> UInt64(n))
    } else {
        return shiftLeft(a: a, n: -n)
    }
}

func floatToInteger(f: Float64) -> (Int64, Bool) {
    let i = Int64(f)
    return (i, Float64(i) == f)
}
