import UIKit

class NumericalDifferentiationLessonViewController: UIViewController {
    private let graphView = GraphView()
    private let diffLabel = UILabel()
    private let functionSelector = UISegmentedControl(items: ["sin(x)", "x²", "eˣ"])
    private let xField = UITextField()
    private let hField = UITextField()
    private let methodSelector = UISegmentedControl(items: ["Forward", "Backward", "Central"])

    private var selectedFunction: (Double) -> Double = { sin($0) }
    private var x: Double = 2.0
    private var h: Double = 0.1
    private var method: String = "Forward"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Numerical Differentiation"
        setupUI()
        updateGraph()
    }

    private func setupUI() {
        graphView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(graphView)
        diffLabel.translatesAutoresizingMaskIntoConstraints = false
        diffLabel.font = .systemFont(ofSize: 18, weight: .bold)
        diffLabel.textAlignment = .center
        view.addSubview(diffLabel)

        functionSelector.selectedSegmentIndex = 0
        functionSelector.addTarget(self, action: #selector(functionChanged), for: .valueChanged)
        functionSelector.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(functionSelector)

        xField.placeholder = "x₀"
        xField.borderStyle = .roundedRect
        xField.keyboardType = .decimalPad
        xField.text = String(x)
        xField.translatesAutoresizingMaskIntoConstraints = false
        xField.addTarget(self, action: #selector(paramChanged), for: .editingChanged)
        view.addSubview(xField)

        hField.placeholder = "h"
        hField.borderStyle = .roundedRect
        hField.keyboardType = .decimalPad
        hField.text = String(h)
        hField.translatesAutoresizingMaskIntoConstraints = false
        hField.addTarget(self, action: #selector(paramChanged), for: .editingChanged)
        view.addSubview(hField)

        methodSelector.selectedSegmentIndex = 0
        methodSelector.addTarget(self, action: #selector(methodChanged), for: .valueChanged)
        methodSelector.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(methodSelector)

        NSLayoutConstraint.activate([
            functionSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            functionSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            functionSelector.widthAnchor.constraint(equalToConstant: 220),

            xField.topAnchor.constraint(equalTo: functionSelector.bottomAnchor, constant: 16),
            xField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            xField.widthAnchor.constraint(equalToConstant: 60),

            hField.topAnchor.constraint(equalTo: functionSelector.bottomAnchor, constant: 16),
            hField.leadingAnchor.constraint(equalTo: xField.trailingAnchor, constant: 16),
            hField.widthAnchor.constraint(equalToConstant: 60),

            methodSelector.topAnchor.constraint(equalTo: functionSelector.bottomAnchor, constant: 16),
            methodSelector.leadingAnchor.constraint(equalTo: hField.trailingAnchor, constant: 16),
            methodSelector.widthAnchor.constraint(equalToConstant: 160),

            graphView.topAnchor.constraint(equalTo: xField.bottomAnchor, constant: 24),
            graphView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            graphView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            graphView.heightAnchor.constraint(equalToConstant: 220),

            diffLabel.topAnchor.constraint(equalTo: graphView.bottomAnchor, constant: 16),
            diffLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            diffLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    @objc private func functionChanged() {
        switch functionSelector.selectedSegmentIndex {
        case 0:
            selectedFunction = { sin($0) }
        case 1:
            selectedFunction = { $0 * $0 }
        case 2:
            selectedFunction = { exp($0) }
        default:
            selectedFunction = { sin($0) }
        }
        updateGraph()
    }

    @objc private func paramChanged() {
        x = Double(xField.text ?? "") ?? x
        h = Double(hField.text ?? "") ?? h
        updateGraph()
    }

    @objc private func methodChanged() {
        let methods = ["Forward", "Backward", "Central"]
        method = methods[methodSelector.selectedSegmentIndex]
        updateGraph()
    }

    private func updateGraph() {
        let viewModel = NumericalDiffViewModel(f: selectedFunction, method: method, h: h, x: x)
        let approx = viewModel.derivativeApprox()
        let tangent = viewModel.tangentLine()
        // Fonksiyon ve türev doğrusu birlikte çizilsin
        graphView.configure(function: selectedFunction, xRange: (x-2)...(x+2), points: [CGPoint(x: x, y: selectedFunction(x))])
        // Türev doğrusunu da çizmek için GraphView'u geliştirmek gerekirse ekleyebilirim.
        diffLabel.text = String(format: "Yaklaşık türev: %.5f", approx)
    }
} 