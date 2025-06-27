import Foundation

struct NumericalDiffViewModel {
    let f: (Double) -> Double
    let method: String // "Forward", "Backward", "Central"
    let h: Double
    let x: Double

    func derivativeApprox() -> Double {
        return derivativeWithStepSize(h)
    }

    func tangentLine() -> (Double) -> Double {
        let slope = derivativeApprox()
        let y0 = f(x)
        return { xVal in slope * (xVal - x) + y0 }
    }
}

// Analysis and optimization extensions
extension NumericalDiffViewModel {
    // Optimal step size calculation
    func findOptimalStepSize() -> Double {
        let machineEpsilon: Double = 1.0e-16
        
        // Function-specific optimal step size calculation
        let sinFunc: (Double) -> Double = { sin($0) }
        let squareFunc: (Double) -> Double = { $0 * $0 }
        let expFunc: (Double) -> Double = { exp($0) }
        
        var optimalH: Double
        
        if functionEquals(f, sinFunc) {
            // For sin(x), optimal h ≈ (machine_epsilon)^(1/3)
            optimalH = pow(machineEpsilon, 1.0/3.0)
        } else if functionEquals(f, squareFunc) {
            // For x², optimal h ≈ (machine_epsilon)^(1/2) / |x|
            optimalH = pow(machineEpsilon, 1.0/2.0) / max(abs(x), 1e-6)
        } else if functionEquals(f, expFunc) {
            // For eˣ, optimal h ≈ (machine_epsilon)^(1/2) / e^|x|
            optimalH = pow(machineEpsilon, 1.0/2.0) / exp(abs(x))
        } else {
            // General case
            optimalH = pow(machineEpsilon, 1.0/3.0)
        }
        
        // Ensure h is within reasonable bounds
        let minH = 1.0e-10
        let maxH = 0.1
        return min(max(optimalH, minH), maxH)
    }
    
    // Error analysis for different step sizes
    func errorAnalysis() -> [(h: Double, error: Double)] {
        var results: [(h: Double, error: Double)] = []
        let exactValue = exactDerivative(x)
        
        // h değerlerini logaritmik ölçekte test et
        for i in -10...0 {
            let testH = pow(10.0, Double(i))
            let approxValue = derivativeWithStepSize(testH)
            let error = abs(approxValue - exactValue)
            results.append((h: testH, error: error))
        }
        
        return results
    }
    
    // Convergence analysis
    func convergenceAnalysis() -> [(iteration: Int, value: Double, error: Double)] {
        var results: [(iteration: Int, value: Double, error: Double)] = []
        let exactValue = exactDerivative(x)
        var currentH = 0.1
        
        for i in 0..<10 {
            let approxValue = derivativeWithStepSize(currentH)
            let error = abs(approxValue - exactValue)
            results.append((iteration: i, value: approxValue, error: error))
            currentH /= 2 // Her iterasyonda adım boyutunu yarıya indir
        }
        
        return results
    }
    
    func exactDerivative(_ x: Double) -> Double {
        let sinFunc: (Double) -> Double = { sin($0) }
        let squareFunc: (Double) -> Double = { $0 * $0 }
        let expFunc: (Double) -> Double = { exp($0) }
        
        if functionEquals(f, sinFunc) {
            return cos(x)
        } else if functionEquals(f, squareFunc) {
            return 2 * x
        } else if functionEquals(f, expFunc) {
            return exp(x)
        }
        return 0
    }
    
    private func functionEquals(_ f1: @escaping (Double) -> Double, _ f2: @escaping (Double) -> Double) -> Bool {
        // Test birkaç nokta için fonksiyonların eşit olup olmadığını kontrol et
        let testPoints = [-1.0, 0.0, 1.0, 2.0, 3.0]
        return testPoints.allSatisfy { abs(f1($0) - f2($0)) < 1e-10 }
    }
    
    func derivativeWithStepSize(_ h: Double) -> Double {
        switch method {
        case "Forward":
            return (f(x + h) - f(x)) / h
        case "Backward":
            return (f(x) - f(x - h)) / h
        case "Central":
            return (f(x + h) - f(x - h)) / (2 * h)
        default:
            return 0
        }
    }
} 