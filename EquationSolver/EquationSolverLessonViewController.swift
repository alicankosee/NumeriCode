import UIKit

struct EquationSolverViewModel {
    let f: (Double) -> Double
    let method: String // "Bisection", "Newton"
    let a: Double
    let b: Double
    let tol: Double

    // Sadece örnek: Bisection adımlarını hesapla
    func bisectionSteps(maxSteps: Int = 10) -> [Double] {
        var steps: [Double] = []
        var left = a
        var right = b
        for _ in 0..<maxSteps {
            let mid = (left + right) / 2
            steps.append(mid)
            if abs(f(mid)) < tol { break }
            if f(left) * f(mid) < 0 {
                right = mid
            } else {
                left = mid
            }
        }
        return steps
    }

    // Newton adımlarını hesapla (örnek)
    func newtonSteps(x0: Double, maxSteps: Int = 10) -> [Double] {
        var steps: [Double] = [x0]
        var x = x0
        for _ in 0..<maxSteps {
            let fx = f(x)
            let dfx = (f(x + 1e-5) - f(x - 1e-5)) / 2e-5
            if abs(dfx) < 1e-8 { break }
            let xNew = x - fx / dfx
            steps.append(xNew)
            if abs(f(xNew)) < tol { break }
            x = xNew
        }
        return steps
    }
}

class EquationSolverLessonViewController: UIViewController {
    private let graphView = GraphView()
    private let resultLabel = UILabel()
    private let functionSelector = UISegmentedControl(items: ["sin(x)", "x²-2", "eˣ-2"])
    private let methodSelector = UISegmentedControl(items: ["Bisection", "Newton"])
    private let aField = UITextField()
    private let bField = UITextField()
    private let tolField = UITextField()
    private let x0Field = UITextField()

    private var selectedFunction: (Double) -> Double = { sin($0) }
    private var a: Double = 0
    private var b: Double = Double.pi
    private var tol: Double = 0.001
    private var x0: Double = 1.0
    private var method: String = "Bisection"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Equation Solver"
        setupUI()
        updateGraph()
    }
    
    private func setupUI() {
        graphView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(graphView)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.font = .systemFont(ofSize: 18, weight: .bold)
        resultLabel.textAlignment = .center
        view.addSubview(resultLabel)

        functionSelector.selectedSegmentIndex = 0
        functionSelector.addTarget(self, action: #selector(functionChanged), for: .valueChanged)
        functionSelector.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(functionSelector)

        methodSelector.selectedSegmentIndex = 0
        methodSelector.addTarget(self, action: #selector(methodChanged), for: .valueChanged)
        methodSelector.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(methodSelector)

        aField.placeholder = "a"
        aField.borderStyle = .roundedRect
        aField.keyboardType = .decimalPad
        aField.text = String(a)
        aField.translatesAutoresizingMaskIntoConstraints = false
        aField.addTarget(self, action: #selector(paramChanged), for: .editingChanged)
        view.addSubview(aField)

        bField.placeholder = "b"
        bField.borderStyle = .roundedRect
        bField.keyboardType = .decimalPad
        bField.text = String(b)
        bField.translatesAutoresizingMaskIntoConstraints = false
        bField.addTarget(self, action: #selector(paramChanged), for: .editingChanged)
        view.addSubview(bField)

        tolField.placeholder = "tol"
        tolField.borderStyle = .roundedRect
        tolField.keyboardType = .decimalPad
        tolField.text = String(tol)
        tolField.translatesAutoresizingMaskIntoConstraints = false
        tolField.addTarget(self, action: #selector(paramChanged), for: .editingChanged)
        view.addSubview(tolField)

        x0Field.placeholder = "x₀ (Newton)"
        x0Field.borderStyle = .roundedRect
        x0Field.keyboardType = .decimalPad
        x0Field.text = String(x0)
        x0Field.translatesAutoresizingMaskIntoConstraints = false
        x0Field.addTarget(self, action: #selector(paramChanged), for: .editingChanged)
        view.addSubview(x0Field)
        
        NSLayoutConstraint.activate([
            functionSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            functionSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            functionSelector.widthAnchor.constraint(equalToConstant: 220),

            methodSelector.topAnchor.constraint(equalTo: functionSelector.bottomAnchor, constant: 16),
            methodSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            methodSelector.widthAnchor.constraint(equalToConstant: 180),
            
            aField.topAnchor.constraint(equalTo: methodSelector.bottomAnchor, constant: 16),
            aField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            aField.widthAnchor.constraint(equalToConstant: 60),

            bField.topAnchor.constraint(equalTo: methodSelector.bottomAnchor, constant: 16),
            bField.leadingAnchor.constraint(equalTo: aField.trailingAnchor, constant: 16),
            bField.widthAnchor.constraint(equalToConstant: 60),

            tolField.topAnchor.constraint(equalTo: methodSelector.bottomAnchor, constant: 16),
            tolField.leadingAnchor.constraint(equalTo: bField.trailingAnchor, constant: 16),
            tolField.widthAnchor.constraint(equalToConstant: 60),

            x0Field.topAnchor.constraint(equalTo: methodSelector.bottomAnchor, constant: 16),
            x0Field.leadingAnchor.constraint(equalTo: tolField.trailingAnchor, constant: 16),
            x0Field.widthAnchor.constraint(equalToConstant: 80),

            graphView.topAnchor.constraint(equalTo: aField.bottomAnchor, constant: 24),
            graphView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            graphView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            graphView.heightAnchor.constraint(equalToConstant: 220),

            resultLabel.topAnchor.constraint(equalTo: graphView.bottomAnchor, constant: 16),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    @objc private func functionChanged() {
        switch functionSelector.selectedSegmentIndex {
        case 0:
            selectedFunction = { sin($0) }
            a = 0; b = Double.pi
        case 1:
            selectedFunction = { $0 * $0 - 2 }
            a = 0; b = 2
        case 2:
            selectedFunction = { exp($0) - 2 }
            a = 0; b = 2
        default:
            selectedFunction = { sin($0) }
            a = 0; b = Double.pi
        }
        aField.text = String(a)
        bField.text = String(b)
        updateGraph()
    }

    @objc private func methodChanged() {
        let methods = ["Bisection", "Newton"]
        method = methods[methodSelector.selectedSegmentIndex]
        updateGraph()
    }
    
    @objc private func paramChanged() {
        a = Double(aField.text ?? "") ?? a
        b = Double(bField.text ?? "") ?? b
        tol = Double(tolField.text ?? "") ?? tol
        x0 = Double(x0Field.text ?? "") ?? x0
        updateGraph()
    }

    private func updateGraph() {
        let viewModel = EquationSolverViewModel(f: selectedFunction, method: method, a: a, b: b, tol: tol)
        var steps: [Double] = []
        if method == "Bisection" {
            steps = viewModel.bisectionSteps()
        } else {
            steps = viewModel.newtonSteps(x0: x0)
        }
        let points = steps.map { CGPoint(x: $0, y: selectedFunction($0)) }
        graphView.configure(function: selectedFunction, xRange: a...b, points: points)
        if let last = steps.last {
            resultLabel.text = String(format: "Son adım: x = %.5f, f(x) = %.5f", last, selectedFunction(last))
        } else {
            resultLabel.text = "Adım bulunamadı."
        }
    }
} 