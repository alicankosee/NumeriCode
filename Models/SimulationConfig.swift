import Foundation

struct SimulationConfig: Codable {
    let module: String
    let simulationTitle: String
    let parameters: [SimulationParameter]
    let output: String
}

struct SimulationParameter: Codable {
    let name: String
    let type: String
    let min: Double?
    let max: Double?
    let defaultValue: SimulationParameterValue
    let options: [String]?
    let description: String

    enum CodingKeys: String, CodingKey {
        case name, type, min, max
        case defaultValue = "default"
        case options, description
    }
}

enum SimulationParameterValue: Codable {
    case double(Double)
    case int(Int)
    case string(String)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.typeMismatch(
                SimulationParameterValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Type not supported")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        }
    }

    var doubleValue: Double? {
        switch self {
        case .double(let d): return d
        case .int(let i): return Double(i)
        case .string(let s): return Double(s)
        case .bool: return nil
        }
    }

    var intValue: Int? {
        switch self {
        case .int(let i): return i
        case .double(let d): return Int(d)
        case .string(let s): return Int(s)
        case .bool: return nil
        }
    }

    var stringValue: String? {
        switch self {
        case .string(let s): return s
        case .double(let d): return String(d)
        case .int(let i): return String(i)
        case .bool(let b): return String(b)
        }
    }

    var boolValue: Bool? {
        switch self {
        case .bool(let b): return b
        case .string(let s): return Bool(s)
        default: return nil
        }
    }
}
