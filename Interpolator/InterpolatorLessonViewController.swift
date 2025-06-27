import UIKit

struct InterpolationViewModel {
    let points: [CGPoint]
    let method: String // "Linear", "Lagrange"

    // Basit lineer enterpolasyon eğrisi (örnek)
    func linearInterpolation(_ x: Double) -> Double {
        guard points.count >= 2 else { return 0 }
        for i in 0..<(points.count-1) {
            let x0 = Double(points[i].x), y0 = Double(points[i].y)
            let x1 = Double(points[i+1].x), y1 = Double(points[i+1].y)
            if x >= x0 && x <= x1 {
                let t = (x - x0) / (x1 - x0)
                return y0 + t * (y1 - y0)
            }
        }
        return 0
    }

    // Basit Lagrange enterpolasyon (örnek)
    func lagrange(_ x: Double) -> Double {
        var result = 0.0
        for i in 0..<points.count {
            var term = Double(points[i].y)
            for j in 0..<points.count {
                if i != j {
                    term *= (x - Double(points[j].x)) / (Double(points[i].x) - Double(points[j].x))
                }
            }
            result += term
        }
        return result
    }

    func interpolationFunction() -> (Double) -> Double {
        switch method {
        case "Linear":
            return { linearInterpolation($0) }
        case "Lagrange":
            return { lagrange($0) }
        default:
            return { linearInterpolation($0) }
        }
    }
}

class InterpolatorLessonViewController: UIViewController {
    private let graphView = GraphView()
    private let methodSelector = UISegmentedControl(items: ["Linear", "Lagrange"])
    private let nStepper = UIStepper()
    private let nLabel = UILabel()
    private var points: [CGPoint] = [CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 2), CGPoint(x: 2, y: 0), CGPoint(x: 3, y: 2)]
    private var method: String = "Linear"
    private var n: Int = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Interpolation"
        setupUI()
        updateGraph()
    }
    
    private func setupUI() {
        graphView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(graphView)
        methodSelector.selectedSegmentIndex = 0
        methodSelector.addTarget(self, action: #selector(methodChanged), for: .valueChanged)
        methodSelector.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(methodSelector)
        nStepper.minimumValue = 2
        nStepper.maximumValue = 10
        nStepper.value = Double(n)
        nStepper.addTarget(self, action: #selector(nChanged), for: .valueChanged)
        nStepper.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nStepper)
        nLabel.text = "n: \(n)"
        nLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nLabel)
        NSLayoutConstraint.activate([
            methodSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            methodSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            methodSelector.widthAnchor.constraint(equalToConstant: 180),
            nLabel.topAnchor.constraint(equalTo: methodSelector.bottomAnchor, constant: 16),
            nLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            nLabel.widthAnchor.constraint(equalToConstant: 50),
            nStepper.centerYAnchor.constraint(equalTo: nLabel.centerYAnchor),
            nStepper.leadingAnchor.constraint(equalTo: nLabel.trailingAnchor, constant: 8),
            nStepper.widthAnchor.constraint(equalToConstant: 80),
            graphView.topAnchor.constraint(equalTo: nLabel.bottomAnchor, constant: 24),
            graphView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            graphView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            graphView.heightAnchor.constraint(equalToConstant: 220),
        ])
    }
    @objc private func methodChanged() {
        let methods = ["Linear", "Lagrange"]
        method = methods[methodSelector.selectedSegmentIndex]
        updateGraph()
    }
    @objc private func nChanged() {
        n = Int(nStepper.value)
        nLabel.text = "n: \(n)"
        // Rastgele yeni noktalar üret
        points = (0..<n).map { i in
            CGPoint(x: Double(i), y: Double.random(in: 0...3))
        }
        updateGraph()
    }
    private func updateGraph() {
        let viewModel = InterpolationViewModel(points: points, method: method)
        let interpFunc = viewModel.interpolationFunction()
        graphView.configure(function: interpFunc, xRange: 0...Double(n-1), points: points)
    }
} 