//
//  DES.swift
//  DUTInfo
//
//  Created by shino on 09/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import Foundation

struct DES {
    static func desStr(text: String, key_1: String, key_2: String, key_3: String) -> String {
        let leng = text.count
        var encData = ""
        let firstKeyBt = getKeyBytes(key_1)
        let firstLength = firstKeyBt.count
        let secondKeyBt = getKeyBytes(key_2)
        let secondLength = secondKeyBt.count
        let thirdKeyBt = getKeyBytes(key_3)
        let thirdLength = thirdKeyBt.count
        if leng > 0 {
            if leng < 4 {
                let bt = strToBt(text)
                var encByte: [Int8]
                var tempBt = bt
                for x in 0 ..< firstLength {
                    tempBt = enc(tempBt, firstKeyBt[x])
                }
                for y in 0 ..< secondLength {
                    tempBt = enc(tempBt, secondKeyBt[y])
                }
                for z in 0 ..< thirdLength {
                    tempBt = enc(tempBt, thirdKeyBt[z])
                }
                encByte = tempBt
                var encByteString = ""
                for i in encByte {
                    encByteString += "\(i)"
                }
                encData = bt64ToHex(encByteString)
            } else {
                let iterator = leng / 4
                let remainder = leng % 4
                for i in 0 ..< iterator {
                    let startIndex = text.index(text.startIndex, offsetBy: i * 4 + 0)
                    let endIndex = text.index(text.startIndex, offsetBy: i * 4 + 4)
                    let tempData = text[startIndex ..< endIndex]
                    let tempByte = strToBt(String(tempData))
                    var encByte: [Int8]
                    var tempBt = tempByte
                    for x in 0 ..< firstLength {
                        tempBt = enc(tempBt, firstKeyBt[x])
                    }
                    for y in 0 ..< secondLength {
                        tempBt = enc(tempBt, secondKeyBt[y])
                    }
                    for z in 0 ..< thirdLength {
                        tempBt = enc(tempBt, thirdKeyBt[z])
                    }
                    encByte = tempBt
                    var encByteString = ""
                    for i in encByte {
                        encByteString += "\(i)"
                    }
                    encData += bt64ToHex(encByteString)
                }
                if remainder > 0 {
                    let startIndex = text.index(text.startIndex, offsetBy: iterator * 4 + 0)
                    let endIndex = text.index(text.startIndex, offsetBy: leng)
                    let remainderData = text[startIndex ..< endIndex]
                    let tempByte = strToBt(String(remainderData))
                    var encByte: [Int8]
                    var tempBt = tempByte
                    for x in 0 ..< firstLength {
                        tempBt = enc(tempBt, firstKeyBt[x])
                    }
                    for y in 0 ..< secondLength {
                        tempBt = enc(tempBt, secondKeyBt[y])
                    }
                    for z in 0 ..< thirdLength {
                        tempBt = enc(tempBt, thirdKeyBt[z])
                    }
                    encByte = tempBt
                    var encByteString = ""
                    for i in encByte {
                        encByteString += "\(i)"
                    }
                    encData += bt64ToHex(encByteString)
                }
            }
        }
        return encData
    }
    
    private static func getKeyBytes(_ key: String) -> [[Int8]] {
        let leng = key.count
        let iterator = leng / 4
        let remainder = leng % 4
        var keyBytes = [[Int8]](repeating: [Int8](repeating: 0, count: 64), count: iterator + 1)
        var i = 0
        for _ in 0 ..< iterator {
            let startIndex = key.index(key.startIndex, offsetBy: i * 4 + 0)
            let endIndex = key.index(key.startIndex, offsetBy: i * 4 + 4)
            keyBytes[i] = strToBt(String(key[startIndex ..< endIndex]))
            i += 1
        }
        if remainder > 0 {
            let startIndex = key.index(key.startIndex, offsetBy: i * 4 + 0)
            let endIndex = key.index(key.startIndex, offsetBy: leng)
            keyBytes[i] = strToBt(String(key[startIndex ..< endIndex]))
        }
        return keyBytes
    }
    
    //字符串与HEX字节转换
    private static func strToBt(_ str: String) -> [Int8] {
        let leng = str.count
        var bt = [Int8](repeating: 0, count: 64)
        if leng < 4 {
            for i in 0 ..< leng {
                let index = str.index(str.startIndex, offsetBy: i)
                let k = str[index].unicodeScalars.first!.value
                for j in 0 ..< 16 {
                    var pow = 1
                    var m = 15
                    while m > j {
                        pow *= 2
                        m -= 1
                    }
                    bt[16 * i + j] = Int8((Int(k) / pow) % 2)
                }
            }
            var p = leng
            while p < 4 {
                for q in 0 ..< 16 {
                    var pow = 1
                    var m = 15
                    while m > q {
                        pow *= 2
                        m -= 1
                    }
                    bt[16 * p + q] = Int8(0 / pow % 2)
                }
                p += 1
            }
        } else {
            for i in 0 ..< 4 {
                let index = str.index(str.startIndex, offsetBy: i)
                
                let k = str[index].unicodeScalars.first!.value
                for j in 0 ..< 16 {
                    var pow = 1
                    var m = 15
                    while m > j {
                        pow *= 2
                        m -= 1
                    }
                    bt[16 * i + j] = Int8((Int(k) / pow) % 2)
                }
            }
        }
        return bt
    }
    
    private static func bt4ToHex(_ binary: String) -> String {
        var hex = ""
        switch binary {
        case "0000":
            hex = "0"
        case "0001":
            hex = "1"
        case "0010":
            hex = "2"
        case "0011":
            hex = "3"
        case "0100":
            hex = "4"
        case "0101":
            hex = "5"
        case "0110":
            hex = "6"
        case "0111":
            hex = "7"
        case "1000":
            hex = "8"
        case "1001":
            hex = "9"
        case "1010":
            hex = "A"
        case "1011":
            hex = "B"
        case "1100":
            hex = "C"
        case "1101":
            hex = "D"
        case "1110":
            hex = "E"
        case "1111":
            hex = "F"
        default:
            break
        }
        return hex
    }
    
    private static func hexToBt4(_ hex: String) -> String {
        var binary = ""
        switch hex {
        case "0":
            binary = "0000"
        case "1":
            binary = "0001"
        case "2":
            binary = "0010"
        case "3":
            binary = "0011"
        case "4":
            binary = "0100"
        case "5":
            binary = "0101"
        case "6":
            binary = "0110"
        case "7":
            binary = "0111"
        case "8":
            binary = "1000"
        case "9":
            binary = "1001"
        case "A":
            binary = "1010"
        case "B":
            binary = "1011"
        case "C":
            binary = "1100"
        case "D":
            binary = "1101"
        case "E":
            binary = "1110"
        case "F":
            binary = "1111"
        default:
            break
        }
        return binary
    }
    
    private static func byteToString(_ byteData: String) -> String {
        var str = ""
        for i in 0 ..< 4 {
            var count = 0
            for j in 0 ..< 16 {
                var pow = 1
                var m = 15
                while m > j {
                    pow *= 2
                    m -= 1
                }
                let index = byteData.index(byteData.startIndex, offsetBy: 16 * i + j)
                count += Int(String(byteData[index]))! * pow
            }
            if count != 0 {
                str += String(String(count).unicodeScalars.first!.value)
            }
        }
        return str
    }
    
    private static func bt64ToHex(_ byteData: String) -> String {
        var hex = ""
        for i in 0 ..< 16 {
            var bt = ""
            for j in 0 ..< 4 {
                let index = byteData.index(byteData.startIndex, offsetBy: i * 4 + j)
                bt += String(byteData[index])
            }
            hex += DES.bt4ToHex(bt)
        }
        return hex
    }
    
    private static func hexToBt64(_ hex: String) -> String {
        var binary = ""
        for i in 0 ..< 16 {
            let index = hex.index(hex.startIndex, offsetBy: i)
            binary += DES.hexToBt4(String(hex[index]))
        }
        return binary
    }
    
    //DES 核心算法
    
    //加密算法
    private static func enc(_ dataByte: [Int8], _ keyByte: [Int8]) -> [Int8] {
        let keys = generateKeys(keyByte)
        let ipByte = initPermute(dataByte)
        var ipLeft = [Int8](repeating: 0, count: 32)
        var ipRight = [Int8](repeating: 0, count: 32)
        var tempLeft = [Int8](repeating: 0, count: 32)
        for k in 0 ..< 32 {
            ipLeft[k] = ipByte[k]
            ipRight[k] = ipByte[32 + k]
        }
        for i in 0 ..< 16 {
            for j in 0 ..< 32 {
                tempLeft[j] = ipLeft[j]
                ipLeft[j] = ipRight[j]
            }
            var key = [Int8](repeating: 0, count: 48)
            for m in 0 ..< 48 {
                key[m] = keys[i][m]
            }
            let tempRight = DES.xor(DES.pPermute(DES.sBoxPermute(DES.xor(DES.expandPermute(ipRight), key))), tempLeft)
            for n in 0 ..< 32 {
                ipRight[n] = tempRight[n]
            }
        }
        var finalData = [Int8](repeating: 0, count: 64)
        for i in 0 ..< 32 {
            finalData[i] = ipRight[i]
            finalData[32 + i] = ipLeft[i]
        }
        return DES.finallyPermute(finalData)
    }
    
    //初始IP变换
    private static func initPermute(_ originalData: [Int8]) -> [Int8] {
        var ipByte = [Int8](repeating: 0, count: 64)
        var m = 1
        var n = 0
        for i in 0 ..< 4 {
            var j = 7
            var k = 0
            while j >= 0 {
                ipByte[i * 8 + k] = originalData[j * 8 + m]
                ipByte[i * 8 + k + 32] = originalData[j * 8 + n]
                j -= 1
                k += 1
            }
            m += 2
            n += 2
        }
        return ipByte
    }
    
    //扩充变换
    private static func expandPermute(_ rightData: [Int8]) -> [Int8] {
        var epByte = [Int8](repeating: 0, count: 48)
        for i in 0 ..< 8 {
            if i == 0 {
                epByte[i * 6 + 0] = rightData[31]
            } else {
                epByte[i * 6 + 0] = rightData[i * 4 - 1]
            }
            epByte[i * 6 + 1] = rightData[i * 4 + 0]
            epByte[i * 6 + 2] = rightData[i * 4 + 1]
            epByte[i * 6 + 3] = rightData[i * 4 + 2]
            epByte[i * 6 + 4] = rightData[i * 4 + 3]
            if i == 7 {
                epByte[i * 6 + 5] = rightData[0]
            } else {
                epByte[i * 6 + 5] = rightData[i * 4 + 4]
            }
        }
        return epByte
    }
    
    //异或运算
    private static func xor(_ byteOne: [Int8], _ byteTwo: [Int8]) -> [Int8] {
        var xorByte = [Int8](repeating: 0, count: byteOne.count)
        for i in 0 ..< byteOne.count {
            xorByte[i] = byteOne[i] ^ byteTwo[i]
        }
        return xorByte
    }
    
    //s盒
    private static func sBoxPermute(_ expandByte: [Int8]) -> [Int8] {
        var sBoxByte = [Int8](repeating:0, count: 32)
        var binary = ""
        let s1 = [
            [14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7],
            [0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8],
            [4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0],
            [15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13]
        ]
        
        let s2 = [
            [15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10],
            [3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5],
            [0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15],
            [13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9]
        ]
        
        let s3 = [
            [10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8],
            [13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1],
            [13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7],
            [1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12]
        ]
        
        let s4 = [
            [7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15],
            [13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9],
            [10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4],
            [3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14]
        ]
        
        let s5 = [
            [2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9],
            [14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6],
            [4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14],
            [11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3]
        ]
        
        let s6 = [
            [12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11],
            [10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8],
            [9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6],
            [4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13]
        ]
        
        let s7 = [
            [4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1],
            [13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6],
            [1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2],
            [6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12]
        ]
        
        let s8 = [
            [13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7],
            [1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2],
            [7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8],
            [2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11]
        ]
        
        for m in 0 ..< 8 {
            var i = Int8(0)
            var j = Int8(0)
            i = expandByte[m * 6 + 0] * Int8(2) + expandByte[m * 6 + 5]
            j = expandByte[m * 6 + 1] * Int8(2) * Int8(2) * Int8(2) +
                expandByte[m * 6 + 2] * Int8(2) * Int8(2) +
                expandByte[m * 6 + 3] * Int8(2) +
                expandByte[m * 6 + 4]
            switch m {
            case 0:
                binary = DES.getBoxBinary(Int8(s1[Int(i)][Int(j)]))
            case 1:
                binary = DES.getBoxBinary(Int8(s2[Int(i)][Int(j)]))
            case 2:
                binary = DES.getBoxBinary(Int8(s3[Int(i)][Int(j)]))
            case 3:
                binary = DES.getBoxBinary(Int8(s4[Int(i)][Int(j)]))
            case 4:
                binary = DES.getBoxBinary(Int8(s5[Int(i)][Int(j)]))
            case 5:
                binary = DES.getBoxBinary(Int8(s6[Int(i)][Int(j)]))
            case 6:
                binary = DES.getBoxBinary(Int8(s7[Int(i)][Int(j)]))
            case 7:
                binary = DES.getBoxBinary(Int8(s8[Int(i)][Int(j)]))
            default:
                break
            }
            let index_0 = binary.startIndex
            let index_1 = binary.index(after: index_0)
            let index_2 = binary.index(after: index_1)
            let index_3 = binary.index(after: index_2)
            sBoxByte[m * 4 + 0] = Int8(Int(String(binary[index_0]))!)
            sBoxByte[m * 4 + 1] = Int8(Int(String(binary[index_1]))!)
            sBoxByte[m * 4 + 2] = Int8(Int(String(binary[index_2]))!)
            sBoxByte[m * 4 + 3] = Int8(Int(String(binary[index_3]))!)
        }
        return sBoxByte
    }
    
    //盒变换
    private static func getBoxBinary(_ i: Int8) -> String {
        var binary = ""
        switch i {
        case Int8(0):
            binary = "0000"
        case Int8(1):
            binary = "0001"
        case Int8(2):
            binary = "0010"
        case Int8(3):
            binary = "0011"
        case Int8(4):
            binary = "0100"
        case Int8(5):
            binary = "0101"
        case Int8(6):
            binary = "0110"
        case Int8(7):
            binary = "0111"
        case Int8(8):
            binary = "1000"
        case Int8(9):
            binary = "1001"
        case Int8(10):
            binary = "1010"
        case Int8(11):
            binary = "1011"
        case Int8(12):
            binary = "1100"
        case Int8(13):
            binary = "1101"
        case Int8(14):
            binary = "1110"
        case Int8(15):
            binary = "1111"
        default:
            break
        }
        return binary
    }
    
    //P盒变换
    private static func pPermute(_ sBoxByte: [Int8]) -> [Int8] {
        var pBoxPermute = [Int8](repeating: 0, count: 32)
        pBoxPermute[0] = sBoxByte[15]
        pBoxPermute[1] = sBoxByte[6]
        pBoxPermute[2] = sBoxByte[19]
        pBoxPermute[3] = sBoxByte[20]
        pBoxPermute[4] = sBoxByte[28]
        pBoxPermute[5] = sBoxByte[11]
        pBoxPermute[6] = sBoxByte[27]
        pBoxPermute[7] = sBoxByte[16]
        pBoxPermute[8] = sBoxByte[0]
        pBoxPermute[9] = sBoxByte[14]
        pBoxPermute[10] = sBoxByte[22]
        pBoxPermute[11] = sBoxByte[25]
        pBoxPermute[12] = sBoxByte[4]
        pBoxPermute[13] = sBoxByte[17]
        pBoxPermute[14] = sBoxByte[30]
        pBoxPermute[15] = sBoxByte[9]
        pBoxPermute[16] = sBoxByte[1]
        pBoxPermute[17] = sBoxByte[7]
        pBoxPermute[18] = sBoxByte[23]
        pBoxPermute[19] = sBoxByte[13]
        pBoxPermute[20] = sBoxByte[31]
        pBoxPermute[21] = sBoxByte[26]
        pBoxPermute[22] = sBoxByte[2]
        pBoxPermute[23] = sBoxByte[8]
        pBoxPermute[24] = sBoxByte[18]
        pBoxPermute[25] = sBoxByte[12]
        pBoxPermute[26] = sBoxByte[29]
        pBoxPermute[27] = sBoxByte[5]
        pBoxPermute[28] = sBoxByte[21]
        pBoxPermute[29] = sBoxByte[10]
        pBoxPermute[30] = sBoxByte[3]
        pBoxPermute[31] = sBoxByte[24]
        return pBoxPermute
    }
    
    private static func finallyPermute(_ endByte: [Int8]) -> [Int8] {
        var fpByte = [Int8](repeating: 0, count: 64)
        fpByte[0] = endByte[39]
        fpByte[1] = endByte[7]
        fpByte[2] = endByte[47]
        fpByte[3] = endByte[15]
        fpByte[4] = endByte[55]
        fpByte[5] = endByte[23]
        fpByte[6] = endByte[63]
        fpByte[7] = endByte[31]
        fpByte[8] = endByte[38]
        fpByte[9] = endByte[6]
        fpByte[10] = endByte[46]
        fpByte[11] = endByte[14]
        fpByte[12] = endByte[54]
        fpByte[13] = endByte[22]
        fpByte[14] = endByte[62]
        fpByte[15] = endByte[30]
        fpByte[16] = endByte[37]
        fpByte[17] = endByte[5]
        fpByte[18] = endByte[45]
        fpByte[19] = endByte[13]
        fpByte[20] = endByte[53]
        fpByte[21] = endByte[21]
        fpByte[22] = endByte[61]
        fpByte[23] = endByte[29]
        fpByte[24] = endByte[36]
        fpByte[25] = endByte[4]
        fpByte[26] = endByte[44]
        fpByte[27] = endByte[12]
        fpByte[28] = endByte[52]
        fpByte[29] = endByte[20]
        fpByte[30] = endByte[60]
        fpByte[31] = endByte[28]
        fpByte[32] = endByte[35]
        fpByte[33] = endByte[3]
        fpByte[34] = endByte[43]
        fpByte[35] = endByte[11]
        fpByte[36] = endByte[51]
        fpByte[37] = endByte[19]
        fpByte[38] = endByte[59]
        fpByte[39] = endByte[27]
        fpByte[40] = endByte[34]
        fpByte[41] = endByte[2]
        fpByte[42] = endByte[42]
        fpByte[43] = endByte[10]
        fpByte[44] = endByte[50]
        fpByte[45] = endByte[18]
        fpByte[46] = endByte[58]
        fpByte[47] = endByte[26]
        fpByte[48] = endByte[33]
        fpByte[49] = endByte[1]
        fpByte[50] = endByte[41]
        fpByte[51] = endByte[9]
        fpByte[52] = endByte[49]
        fpByte[53] = endByte[17]
        fpByte[54] = endByte[57]
        fpByte[55] = endByte[25]
        fpByte[56] = endByte[32]
        fpByte[57] = endByte[0]
        fpByte[58] = endByte[40]
        fpByte[59] = endByte[8]
        fpByte[60] = endByte[48]
        fpByte[61] = endByte[16]
        fpByte[62] = endByte[56]
        fpByte[63] = endByte[24]
        return fpByte
    }
    
    //密钐变换
    private static func generateKeys(_ keyByte: [Int8]) -> [[Int8]] {
        var key = [Int8](repeating: 0, count: 56)
        var keys = [[Int8]](repeating: [Int8](repeating: 0, count: 48), count: 16)
        let loop = [1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1]
        for i in 0 ..< 7 {
            var k = 7
            for j in 0 ..< 8 {
                key[i * 8 + j] = keyByte[8 * k + i]
                k -= 1
            }
        }
        for i in 0 ..< 16 {
            var tempLeft = Int8(0)
            var tempRight = Int8(0)
            for _ in 0 ..< loop[i] {
                tempLeft = key[0]
                tempRight = key[28]
                for k in 0 ..< 27 {
                    key[k] = key[k + 1]
                    key[28 + k] = key[29 + k]
                }
                key[27] = tempLeft
                key[55] = tempRight
            }
            var tempKey = [Int8](repeating: 0, count: 48)
            tempKey[0] = key[13]
            tempKey[1] = key[16]
            tempKey[2] = key[10]
            tempKey[3] = key[23]
            tempKey[4] = key[0]
            tempKey[5] = key[4]
            tempKey[6] = key[2]
            tempKey[7] = key[27]
            tempKey[8] = key[14]
            tempKey[9] = key[5]
            tempKey[10] = key[20]
            tempKey[11] = key[9]
            tempKey[12] = key[22]
            tempKey[13] = key[18]
            tempKey[14] = key[11]
            tempKey[15] = key[3]
            tempKey[16] = key[25]
            tempKey[17] = key[7]
            tempKey[18] = key[15]
            tempKey[19] = key[6]
            tempKey[20] = key[26]
            tempKey[21] = key[19]
            tempKey[22] = key[12]
            tempKey[23] = key[1]
            tempKey[24] = key[40]
            tempKey[25] = key[51]
            tempKey[26] = key[30]
            tempKey[27] = key[36]
            tempKey[28] = key[46]
            tempKey[29] = key[54]
            tempKey[30] = key[29]
            tempKey[31] = key[39]
            tempKey[32] = key[50]
            tempKey[33] = key[44]
            tempKey[34] = key[32]
            tempKey[35] = key[47]
            tempKey[36] = key[43]
            tempKey[37] = key[48]
            tempKey[38] = key[38]
            tempKey[39] = key[55]
            tempKey[40] = key[33]
            tempKey[41] = key[52]
            tempKey[42] = key[45]
            tempKey[43] = key[41]
            tempKey[44] = key[49]
            tempKey[45] = key[35]
            tempKey[46] = key[28]
            tempKey[47] = key[31]
            switch i {
            case 0:
                for m in 0 ..< 48 {
                    keys[0][m] = tempKey[m]
                }
            case 1:
                for m in 0 ..< 48 {
                    keys[1][m] = tempKey[m]
                }
            case 2:
                for m in 0 ..< 48 {
                    keys[2][m] = tempKey[m]
                }
            case 3:
                for m in 0 ..< 48 {
                    keys[3][m] = tempKey[m]
                }
            case 4:
                for m in 0 ..< 48 {
                    keys[4][m] = tempKey[m]
                }
            case 5:
                for m in 0 ..< 48 {
                    keys[5][m] = tempKey[m]
                }
            case 6:
                for m in 0 ..< 48 {
                    keys[6][m] = tempKey[m]
                }
            case 7:
                for m in 0 ..< 48 {
                    keys[7][m] = tempKey[m]
                }
            case 8:
                for m in 0 ..< 48 {
                    keys[8][m] = tempKey[m]
                }
            case 9:
                for m in 0 ..< 48 {
                    keys[9][m] = tempKey[m]
                }
            case 10:
                for m in 0 ..< 48 {
                    keys[10][m] = tempKey[m]
                }
            case 11:
                for m in 0 ..< 48 {
                    keys[11][m] = tempKey[m]
                }
            case 12:
                for m in 0 ..< 48 {
                    keys[12][m] = tempKey[m]
                }
            case 13:
                for m in 0 ..< 48 {
                    keys[13][m] = tempKey[m]
                }
            case 14:
                for m in 0 ..< 48 {
                    keys[14][m] = tempKey[m]
                }
            case 15:
                for m in 0 ..< 48 {
                    keys[15][m] = tempKey[m]
                }
            default:
                break
            }
        }
        return keys
    }
}
