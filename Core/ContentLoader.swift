import Foundation

struct ModuleContent: Codable {
    let lesson: LessonContent
    let quiz: [QuizQuestion]
}

enum ModuleType: Int {
    case numericalDifferentiation = 0
    case numericalIntegration = 1
    case linearSystemSolver = 2
    case luDecomposition = 3
    case optimization = 4
    case odeSolver = 5
    case performance = 6
    case equationSolver = 7
    case errorLab = 8
    case interpolator = 9
    
    var contentFileName: String {
        switch self {
        case .numericalDifferentiation:
            return "numerical_differentiation_content"
        case .numericalIntegration:
            return "numerical_integration_content"
        case .linearSystemSolver:
            return "linear_system_solver_content"
        case .luDecomposition:
            return "lu_decomposition_content"
        case .optimization:
            return "optimization_content"
        case .odeSolver:
            return "ode_solver_content"
        case .performance:
            return "performance_analysis_content"
        case .equationSolver:
            return "equation_solver_content"
        case .errorLab:
            return "error_lab_content"
        case .interpolator:
            return "interpolator_content"
        }
    }
}

class ContentLoader {
    static func loadContent(for module: ModuleType) -> ModuleContent? {
        let fileName = module.contentFileName
        print("Loading content from file: \(fileName).json")
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Error: File \(fileName).json not found.")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let content = try decoder.decode(ModuleContent.self, from: data)
            print("Loaded lesson: \(content.lesson.title), paragraphs: \(content.lesson.paragraphs.count)")
            print("Loaded quiz questions: \(content.quiz.count)")
            assert(!content.lesson.title.isEmpty, "Lesson title should not be empty")
            assert((8...10).contains(content.quiz.count), "Quiz should have 8–10 questions")
            return content
        } catch {
            print("Error decoding \(fileName).json: \(error)")
            return nil
        }
    }

    func loadContent(fileName: String) -> LessonContent? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let content = try JSONDecoder().decode(LessonContent.self, from: data)
            return content
        } catch {
            return nil
        }
    }
}
 