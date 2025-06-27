import Foundation

struct QuizQuestion: Codable {
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
} 