/// Implementations of BinaryCodable for built-in types.

import Foundation


extension Array where Element: BinaryDecodable {
    public func binaryEncode(to encoder: BinaryEncoder) throws {
        guard Element.self is Encodable.Type else {
            throw BinaryEncoder.Error.typeNotConformingToEncodable(Element.self)
        }
        
        try encoder.encode(self.count)
        for element in self {
            try (element as! Encodable).encode(to: encoder)
        }
    }
    
    public init(from decoder: Decoder) throws {
        guard let binaryElement = Element.self as? Decodable.Type else {
            throw BinaryDecoder.Error.typeNotConformingToDecodable(Element.self)
        }
        
        let binaryDecoder = decoder as! BinaryDecoder
        let count = try binaryDecoder.decode(Int.self)
        self.init()
        self.reserveCapacity(count)
        for _ in 0 ..< count {
            let decoded = try binaryElement.init(from: decoder)
            self.append(decoded as! Element)
        }
    }
}

extension String: BinaryCodable {
    public func binaryEncode(to encoder: BinaryEncoder) throws {
        try Array(self.utf8).binaryEncode(to: encoder)
    }
    
    public init(fromBinary decoder: BinaryDecoder) throws {
        let utf8: [UInt8] = try Array(from: decoder)
        if let str = String(bytes: utf8, encoding: .utf8) {
            self = str
        } else {
            throw BinaryDecoder.Error.invalidUTF8(utf8)
        }
    }
}

extension FixedWidthInteger where Self: BinaryEncodable {
    public func binaryEncode(to encoder: BinaryEncoder) {
        encoder.appendBytes(of: self.bigEndian)
    }
}

extension FixedWidthInteger where Self: BinaryDecodable {
    public init(fromBinary binaryDecoder: BinaryDecoder) throws {
        var v = Self.init()
        try binaryDecoder.read(into: &v)
        self.init(bigEndian: v)
    }
}

// for size in [8, 16, 32, 64] {
//     for prefix in ["", "U"] {
//         print("extension \(prefix)Int\(size): BinaryCodable {}")
//     }
// }
// Copy the above snippet, then run: `pbpaste | swift`
extension Int8: BinaryCodable {}
extension UInt8: BinaryCodable {}
extension Int16: BinaryCodable {}
extension UInt16: BinaryCodable {}
extension Int32: BinaryCodable {}
extension UInt32: BinaryCodable {}
extension Int64: BinaryCodable {}
extension UInt64: BinaryCodable {}

extension Data: BinaryEncodable {
    public func binaryEncode(to encoder: BinaryEncoder) {
        let array = [UInt8](self)
        try! array.binaryEncode(to: encoder)
        // TODO: faster
//        try! encoder.encode(self.count)
//        encoder.appendBytes(of: self)
    }
}

extension Data: BinaryDecodable {
    public init(fromBinary binaryDecoder: BinaryDecoder) throws {
        let size: Int = try! binaryDecoder.decode(Int.self)
        
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        try binaryDecoder.read(size, into: pointer)
        self.init(bytesNoCopy: pointer, count: size, deallocator: .custom({ (ptr, s) in
            ptr.deallocate()
        }))
    }
}
