import Foundation

struct LinearSystemStep {
    let description: String
    let matrix: [[Double]]
    let vector: [Double]
}

class LinearSystemSolverViewModel {
    let size: Int
    var steps: [LinearSystemStep] = []

    // Sabit 3x3 sistem
    let A: [[Double]] = [
        [10, 2, 1],
        [2, 20, -2],
        [-2, 3, 10]
    ]
    let b: [Double] = [9, -44, 22]
    let n = 3

    init(size: Int) {
        self.size = size
    }

    func solve() -> [LinearSystemStep] {
        // Dinamik olarak birim matris ve b vektörü oluştur
        var A: [[Double]] = (0..<size).map { i in
            (0..<size).map { j in i == j ? 1.0 : 0.0 }
        }
        var b: [Double] = Array(1...size).map { Double($0) }
        let n = size

        steps.append(LinearSystemStep(description: "Başlangıç Matrisi", matrix: A, vector: b))

        // Gauss eliminasyonu (çok basit, pivot kontrolü yok)
        for k in 0..<n {
            for i in (k+1)..<n {
                let factor = A[i][k] / A[k][k]
                for j in k..<n {
                    A[i][j] -= factor * A[k][j]
                }
                b[i] -= factor * b[k]
            }
            steps.append(LinearSystemStep(description: "\(k+1). adım", matrix: A, vector: b))
        }

        // Geriye doğru yerine koyma
        var x = Array(repeating: 0.0, count: n)
        for i in stride(from: n-1, through: 0, by: -1) {
            var sum = b[i]
            for j in (i+1)..<n {
                sum -= A[i][j] * x[j]
            }
            x[i] = sum / A[i][i]
        }
        steps.append(LinearSystemStep(description: "Çözüm", matrix: A, vector: x))
        return steps
    }

    // Gaussian Elimination
    func solveUsingGaussianElimination() -> [String] {
        var log: [String] = []
        var A = self.A
        var b = self.b
        log.append("Başlangıç Matrisi ve vektör:")
        log.append(matrixString(A, b: b))
        // İleri eliminasyon
        for k in 0..<n-1 {
            for i in (k+1)..<n {
                let factor = A[i][k] / A[k][k]
                let stepDesc = "Adım: Satır \(i+1)'den \(String(format: "%.4f", factor)) × Satır \(k+1) çıkarılıyor."
                log.append(stepDesc)
                for j in k..<n {
                    A[i][j] -= factor * A[k][j]
                }
                b[i] -= factor * b[k]
                log.append("Güncel matris ve vektör:")
                log.append(matrixString(A, b: b))
            }
        }
        // Geri yerine koyma
        log.append("Geri yerine koyma aşaması:")
        var x = Array(repeating: 0.0, count: n)
        for i in stride(from: n-1, through: 0, by: -1) {
            var sum = b[i]
            for j in (i+1)..<n {
                sum -= A[i][j] * x[j]
            }
            x[i] = sum / A[i][i]
            log.append("x\(i+1) hesaplanıyor: (b[\(i)] - diğer terimler) / A[\(i)][\(i)] = \(String(format: "%.4f", x[i]))")
        }
        log.append("Sonuç: x₁ = \(String(format: "%.4f", x[0])), x₂ = \(String(format: "%.4f", x[1])), x₃ = \(String(format: "%.4f", x[2]))")
        return log
    }
    
    // Jacobi Iteration
    func solveUsingJacobi(tolerance: Double = 1e-6, maxIterations: Int = 25) -> [String] {
        var log: [String] = []
        var x = Array(repeating: 0.0, count: n)
        var xOld = x
        log.append("Başlangıç: x₁ = 0, x₂ = 0, x₃ = 0")
        for iter in 1...maxIterations {
            log.append("\(iter). iterasyon:")
            for i in 0..<n {
                var sum = b[i]
                for j in 0..<n {
                    if i != j {
                        sum -= A[i][j] * xOld[j]
                    }
                }
                let newXi = sum / A[i][i]
                log.append("  Yeni x\(i+1) = (b[\(i)] - diğer terimler) / A[\(i)][\(i)] = \(String(format: "%.6f", newXi))")
                x[i] = newXi
            }
            let diff = zip(x, xOld).map { abs($0 - $1) }.max() ?? 0.0
            log.append("  x güncellendi: x₁ = \(String(format: "%.6f", x[0])), x₂ = \(String(format: "%.6f", x[1])), x₃ = \(String(format: "%.6f", x[2]))")
            log.append("  Maksimum değişim: \(String(format: "%.2e", diff))")
            if diff < tolerance {
                log.append("  Yakınsama sağlandı. Çözüm bulundu.")
                break
            }
            xOld = x
        }
        log.append("Sonuç: x₁ = \(String(format: "%.6f", x[0])), x₂ = \(String(format: "%.6f", x[1])), x₃ = \(String(format: "%.6f", x[2]))")
        return log
    }
    
    // Gauss-Seidel Iteration
    func solveUsingGaussSeidel(tolerance: Double = 1e-6, maxIterations: Int = 25) -> [String] {
        var log: [String] = []
        var x = Array(repeating: 0.0, count: n)
        log.append("Başlangıç: x₁ = 0, x₂ = 0, x₃ = 0")
        for iter in 1...maxIterations {
            log.append("\(iter). iterasyon:")
            var xOld = x
            for i in 0..<n {
                var sum = b[i]
                for j in 0..<n {
                    if i != j {
                        sum -= A[i][j] * x[j]
                    }
                }
                let newXi = sum / A[i][i]
                log.append("  Yeni x\(i+1) = (b[\(i)] - diğer terimler) / A[\(i)][\(i)] = \(String(format: "%.6f", newXi))")
                x[i] = newXi
            }
            let diff = zip(x, xOld).map { abs($0 - $1) }.max() ?? 0.0
            log.append("  x güncellendi: x₁ = \(String(format: "%.6f", x[0])), x₂ = \(String(format: "%.6f", x[1])), x₃ = \(String(format: "%.6f", x[2]))")
            log.append("  Maksimum değişim: \(String(format: "%.2e", diff))")
            if diff < tolerance {
                log.append("  Yakınsama sağlandı. Çözüm bulundu.")
                break
            }
        }
        log.append("Sonuç: x₁ = \(String(format: "%.6f", x[0])), x₂ = \(String(format: "%.6f", x[1])), x₃ = \(String(format: "%.6f", x[2]))")
        return log
    }
    
    // Yardımcı: Matrisi ve vektörü stringe çevir
    private func matrixString(_ A: [[Double]], b: [Double]) -> String {
        var s = ""
        for i in 0..<n {
            s += "[" + A[i].map { String(format: "%7.4f", $0) }.joined(separator: ", ") + "] | " + String(format: "%7.4f", b[i]) + "\n"
        }
        return s
    }
} 