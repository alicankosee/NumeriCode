import Foundation

class ModuleProgressManager {
    static let shared = ModuleProgressManager()
    private let completedModulesKey = "completedModules"
    private let userDefaults = UserDefaults.standard

    private init() {}

    func markCompleted(module: String) {
        var completed = completedModules()
        if !completed.contains(module) {
            completed.append(module)
            userDefaults.set(completed, forKey: completedModulesKey)
        }
    }

    func isCompleted(module: String) -> Bool {
        let completed = completedModules()
        return completed.contains(module)
    }

    func completedModules() -> [String] {
        return userDefaults.stringArray(forKey: completedModulesKey) ?? []
    }

    func completedCount(totalModules: Int) -> String {
        let count = completedModules().count
        return "\(count)/\(totalModules) modules completed"
    }

    func unmarkCompleted(module: String) {
        var completed = completedModules()
        completed.removeAll { $0 == module }
        userDefaults.set(completed, forKey: completedModulesKey)
    }
}