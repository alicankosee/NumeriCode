import Foundation

class SimulationConfigLoader {
    static func loadConfig(for module: ModuleType) -> SimulationConfig? {
        let fileName: String
        switch module {
        case .errorLab: fileName = "error_analysis"
        case .equationSolver: fileName = "equation_solver"
        case .interpolator: fileName = "interpolation"
        case .numericalDifferentiation: fileName = "numerical_differentiation"
        case .numericalIntegration: fileName = "numerical_integration"
        case .linearSystemSolver: fileName = "linear_systems"
        case .luDecomposition: fileName = "lu_decomposition"
        case .optimization: fileName = "optimization"
        case .odeSolver: fileName = "ode_solver"
        case .performance: fileName = "performance_analysis"
        }
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Content") {
            print("Found config at: \(url)")
        } else {
            print("NOT FOUND: \(fileName).json in Content")
        }
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Content") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(SimulationConfig.self, from: data)
            return config
        } catch {
            print("Simulation config load error: \(error)")
            return nil
        }
    }
}
