import Foundation
 
struct LessonContent: Codable {
    let title: String
    let paragraphs: [String]
    let formula: String?
} 