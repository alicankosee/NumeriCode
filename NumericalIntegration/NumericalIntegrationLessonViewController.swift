import UIKit

struct NumericalIntegrationLessonViewModel {
    let f: (Double) -> Double
    let a: Double
    let b: Double
    let n: Int

    func trapezoidalValue() -> Double {
        let h = (b - a) / Double(n)
        var sum = 0.5 * (f(a) + f(b))
        for i in 1..<n {
            sum += f(a + Double(i) * h)
        }
        return sum * h
    }

    func trapezoidPoints() -> [[CGPoint]] {
        let h = (b - a) / Double(n)
        var result: [[CGPoint]] = []
        for i in 0..<n {
            let x0 = a + Double(i) * h
            let x1 = x0 + h
            result.append([
                CGPoint(x: x0, y: 0),
                CGPoint(x: x0, y: f(x0)),
                CGPoint(x: x1, y: f(x1)),
                CGPoint(x: x1, y: 0)
            ])
        }
        return result
    }
}

class NumericalIntegrationLessonViewController: UIViewController {
    private let graphView = GraphView()
    private let areaLabel = UILabel()
    private let functionSelector = UISegmentedControl(items: ["sin(x)", "x²", "eˣ"])
    private let aField = UITextField()
    private let bField = UITextField()
    private let nStepper = UIStepper()
    private let nLabel = UILabel()

    private var selectedFunction: (Double) -> Double = { sin($0) }
    private var a: Double = 0
    private var b: Double = Double.pi
    private var n: Int = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Numerical Integration"
        setupUI()
        updateGraph()
    }

    private func setupUI() {
        graphView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(graphView)
        areaLabel.translatesAutoresizingMaskIntoConstraints = false
        areaLabel.font = .systemFont(ofSize: 18, weight: .bold)
        areaLabel.textAlignment = .center
        view.addSubview(areaLabel)

        functionSelector.selectedSegmentIndex = 0
        functionSelector.addTarget(self, action: #selector(functionChanged), for: .valueChanged)
        functionSelector.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(functionSelector)

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

        nStepper.minimumValue = 2
        nStepper.maximumValue = 100
        nStepper.value = Double(n)
        nStepper.addTarget(self, action: #selector(paramChanged), for: .valueChanged)
        nStepper.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nStepper)

        nLabel.text = "n: \(n)"
        nLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nLabel)

        NSLayoutConstraint.activate([
            functionSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            functionSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            functionSelector.widthAnchor.constraint(equalToConstant: 220),

            aField.topAnchor.constraint(equalTo: functionSelector.bottomAnchor, constant: 16),
            aField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            aField.widthAnchor.constraint(equalToConstant: 60),

            bField.topAnchor.constraint(equalTo: functionSelector.bottomAnchor, constant: 16),
            bField.leadingAnchor.constraint(equalTo: aField.trailingAnchor, constant: 16),
            bField.widthAnchor.constraint(equalToConstant: 60),

            nLabel.topAnchor.constraint(equalTo: functionSelector.bottomAnchor, constant: 16),
            nLabel.leadingAnchor.constraint(equalTo: bField.trailingAnchor, constant: 16),
            nLabel.widthAnchor.constraint(equalToConstant: 50),

            nStepper.centerYAnchor.constraint(equalTo: nLabel.centerYAnchor),
            nStepper.leadingAnchor.constraint(equalTo: nLabel.trailingAnchor, constant: 8),
            nStepper.widthAnchor.constraint(equalToConstant: 80),

            graphView.topAnchor.constraint(equalTo: aField.bottomAnchor, constant: 24),
            graphView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            graphView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            graphView.heightAnchor.constraint(equalToConstant: 220),

            areaLabel.topAnchor.constraint(equalTo: graphView.bottomAnchor, constant: 16),
            areaLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            areaLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    @objc private func functionChanged() {
        switch functionSelector.selectedSegmentIndex {
        case 0:
            selectedFunction = { sin($0) }
            a = 0; b = Double.pi
        case 1:
            selectedFunction = { $0 * $0 }
            a = 0; b = 2
        case 2:
            selectedFunction = { exp($0) }
            a = 0; b = 1
        default:
            selectedFunction = { sin($0) }
            a = 0; b = Double.pi
        }
        aField.text = String(a)
        bField.text = String(b)
        updateGraph()
    }

    @objc private func paramChanged() {
        a = Double(aField.text ?? "") ?? a
        b = Double(bField.text ?? "") ?? b
        n = Int(nStepper.value)
        nLabel.text = "n: \(n)"
        updateGraph()
    }

    private func updateGraph() {
        let viewModel = NumericalIntegrationViewModel(f: selectedFunction, a: a, b: b, n: n)
        let area = viewModel.trapezoidalValue()
        let polygons = viewModel.trapezoidPoints()
        graphView.configure(function: selectedFunction, xRange: a...b)
        graphView.fillPolygons(polygons)
        areaLabel.text = String(format: "Alan (Trapez Yöntemi): %.5f", area)
    }
} 
