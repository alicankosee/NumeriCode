import Foundation

class SimulationViewModel {
    // Örnek: Bisection yöntemi için temel state
    struct State {
        let a: Double
        let b: Double
        let fa: Double
        let fb: Double
        let mid: Double
        let fmid: Double
        let iteration: Int
    }
    
    var onStateUpdate: ((State) -> Void)?
    private(set) var states: [State] = []
    private var currentIteration = 0
    
    // Örnek fonksiyon: f(x) = x^2 - 2
    private func f(_ x: Double) -> Double {
        return x * x - 2
    }
    
    func startBisection(a: Double, b: Double, maxIter: Int = 10) {
        states = []
        currentIteration = 0
        var a = a
        var b = b
        var fa = f(a)
        var fb = f(b)
        for i in 1...maxIter {
            let mid = (a + b) / 2
            let fmid = f(mid)
            let state = State(a: a, b: b, fa: fa, fb: fb, mid: mid, fmid: fmid, iteration: i)
            states.append(state)
            if abs(fmid) < 1e-6 { break }
            if fa * fmid < 0 {
                b = mid
                fb = fmid
            } else {
                a = mid
                fa = fmid
            }
        }
        currentIteration = 0
        if let first = states.first {
            onStateUpdate?(first)
        }
    }
    
    func nextStep() {
        guard currentIteration + 1 < states.count else { return }
        currentIteration += 1
        onStateUpdate?(states[currentIteration])
    }
    
    func prevStep() {
        guard currentIteration - 1 >= 0 else { return }
        currentIteration -= 1
        onStateUpdate?(states[currentIteration])
    }
} 