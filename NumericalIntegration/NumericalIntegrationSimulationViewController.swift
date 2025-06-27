import UIKit

struct NumericalIntegrationViewModel {
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
    
    func simpsonValue() -> Double {
        guard n % 2 == 0 else { return trapezoidalValue() }
        let h = (b - a) / Double(n)
        var sum = f(a) + f(b)
        for i in 1..<n {
            let x = a + Double(i) * h
            sum += (i % 2 == 0 ? 2 : 4) * f(x)
        }
        return sum * h / 3.0
    }
    
    func midpointValue() -> Double {
        let h = (b - a) / Double(n)
        var sum = 0.0
        for i in 0..<n {
            let x = a + Double(i) * h + h/2
            sum += f(x)
        }
        return sum * h
    }
    
    func trapezoidPoints() -> [[CGPoint]] {
        let h = (b - a) / Double(n)
        var polygons: [[CGPoint]] = []
        
        for i in 0..<n {
            let x1 = a + Double(i) * h
            let x2 = x1 + h
            let y1 = f(x1)
            let y2 = f(x2)
            
            let polygon = [
                CGPoint(x: x1, y: 0),
                CGPoint(x: x1, y: y1),
                CGPoint(x: x2, y: y2),
                CGPoint(x: x2, y: 0)
            ]
            polygons.append(polygon)
        }
        return polygons
    }
    
    func simpsonPoints() -> [[CGPoint]] {
        let h = (b - a) / Double(n)
        var polygons: [[CGPoint]] = []
        
        for i in stride(from: 0, to: n, by: 2) {
            let x1 = a + Double(i) * h
            let x2 = x1 + h
            let x3 = x2 + h
            let y1 = f(x1)
            let y2 = f(x2)
            let y3 = f(x3)
            
            let polygon = [
                CGPoint(x: x1, y: 0),
                CGPoint(x: x1, y: y1),
                CGPoint(x: x2, y: y2),
                CGPoint(x: x3, y: y3),
                CGPoint(x: x3, y: 0)
            ]
            polygons.append(polygon)
        }
        return polygons
    }
    
    func midpointPoints() -> [[CGPoint]] {
        let h = (b - a) / Double(n)
        var polygons: [[CGPoint]] = []
        
        for i in 0..<n {
            let x1 = a + Double(i) * h
            let x2 = x1 + h
            let midX = x1 + h/2
            let midY = f(midX)
            
            let polygon = [
                CGPoint(x: x1, y: 0),
                CGPoint(x: x1, y: midY),
                CGPoint(x: x2, y: midY),
                CGPoint(x: x2, y: 0)
            ]
            polygons.append(polygon)
        }
        return polygons
    }
}

class NumericalIntegrationSimulationViewController: UIViewController {
    // UI Components
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let graphView = GraphView()
    private let resultLabel = UILabel()
    private let methodSelector = UISegmentedControl(items: ["Trapezoidal", "Simpson's", "Midpoint"])
    private let functionSelector = UISegmentedControl(items: ["x²", "sin(x)", "eˣ", "1/(1+x²)"])
    private let nSlider = UISlider()
    private let nLabel = UILabel()
    private let aField = UITextField()
    private let bField = UITextField()

    private var selectedFunction: (Double) -> Double = { $0 * $0 }
    private var selectedFunctionIndex: Int = 0
    private var a: Double = 0
    private var b: Double = 1
    private var n: Int = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Numerical Integration"
        setupUI()
        updateGraphAndOutput()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        contentStack.isLayoutMarginsRelativeArrangement = true
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Educational explanation: Function
        let functionInfo = UILabel()
        functionInfo.text = "Select a function to see how its definite integral is approximated."
        functionInfo.font = .systemFont(ofSize: 13)
        functionInfo.textColor = .secondaryLabel
        functionInfo.numberOfLines = 0
        contentStack.addArrangedSubview(functionInfo)

        // Function selector
        let functionLabel = UILabel()
        functionLabel.text = "Function:"
        functionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentStack.addArrangedSubview(functionLabel)
        
        functionSelector.selectedSegmentIndex = 0
        functionSelector.addTarget(self, action: #selector(functionChanged), for: .valueChanged)
        contentStack.addArrangedSubview(functionSelector)

        // Educational explanation: Method
        let methodInfo = UILabel()
        methodInfo.text = "Choose a numerical integration method. Each method uses a different approach to estimate the area under the curve."
        methodInfo.font = .systemFont(ofSize: 13)
        methodInfo.textColor = .secondaryLabel
        methodInfo.numberOfLines = 0
        contentStack.addArrangedSubview(methodInfo)

        // Method selector
        let methodLabel = UILabel()
        methodLabel.text = "Method:"
        methodLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentStack.addArrangedSubview(methodLabel)
        
        methodSelector.selectedSegmentIndex = 0
        methodSelector.addTarget(self, action: #selector(methodChanged), for: .valueChanged)
        contentStack.addArrangedSubview(methodSelector)

        // Educational explanation: Interval/n
        let intervalInfo = UILabel()
        intervalInfo.text = "Set the lower and upper bounds of integration and the number of intervals (n). Increasing n usually increases accuracy."
        intervalInfo.font = .systemFont(ofSize: 13)
        intervalInfo.textColor = .secondaryLabel
        intervalInfo.numberOfLines = 0
        contentStack.addArrangedSubview(intervalInfo)

        // Input fields
        let inputContainer = UIStackView()
        inputContainer.axis = .horizontal
        inputContainer.spacing = 16
        inputContainer.distribution = .fillEqually
        
        // a input
        let aContainer = UIStackView()
        aContainer.axis = .vertical
        aContainer.spacing = 8
        
        let aLabel = UILabel()
        aLabel.text = "Lower bound (a):"
        aLabel.font = .systemFont(ofSize: 14)
        aContainer.addArrangedSubview(aLabel)
        
        aField.placeholder = "a"
        aField.borderStyle = .roundedRect
        aField.keyboardType = .decimalPad
        aField.text = String(a)
        aField.addTarget(self, action: #selector(paramChanged), for: .editingChanged)
        aContainer.addArrangedSubview(aField)
        
        inputContainer.addArrangedSubview(aContainer)
        
        // b input
        let bContainer = UIStackView()
        bContainer.axis = .vertical
        bContainer.spacing = 8
        
        let bLabel = UILabel()
        bLabel.text = "Upper bound (b):"
        bLabel.font = .systemFont(ofSize: 14)
        bContainer.addArrangedSubview(bLabel)
        
        bField.placeholder = "b"
        bField.borderStyle = .roundedRect
        bField.keyboardType = .decimalPad
        bField.text = String(b)
        bField.addTarget(self, action: #selector(paramChanged), for: .editingChanged)
        bContainer.addArrangedSubview(bField)
        
        inputContainer.addArrangedSubview(bContainer)
        
        contentStack.addArrangedSubview(inputContainer)

        // n slider
        let nContainer = UIStackView()
        nContainer.axis = .vertical
        nContainer.spacing = 8
        
        let nTitleLabel = UILabel()
        nTitleLabel.text = "Number of intervals (n):"
        nTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nContainer.addArrangedSubview(nTitleLabel)
        
        let nValueContainer = UIStackView()
        nValueContainer.axis = .horizontal
        nValueContainer.spacing = 16
        nValueContainer.alignment = .center
        
        nSlider.minimumValue = 2
        nSlider.maximumValue = 50
        nSlider.value = Float(n)
        nSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        nValueContainer.addArrangedSubview(nSlider)
        
        nLabel.text = "\(n)"
        nLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nLabel.setContentHuggingPriority(.required, for: .horizontal)
        nValueContainer.addArrangedSubview(nLabel)
        
        nContainer.addArrangedSubview(nValueContainer)
        contentStack.addArrangedSubview(nContainer)

        // Educational explanation: Graph
        let graphInfo = UILabel()
        graphInfo.text = "The graph below shows the selected function and the area estimated by the chosen method."
        graphInfo.font = .systemFont(ofSize: 13)
        graphInfo.textColor = .secondaryLabel
        graphInfo.numberOfLines = 0
        contentStack.addArrangedSubview(graphInfo)

        // Graph
        let graphTitle = UILabel()
        graphTitle.text = "Function and Integration Area"
        graphTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        graphTitle.textAlignment = .center
        contentStack.addArrangedSubview(graphTitle)
        
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        contentStack.addArrangedSubview(graphView)

        // Educational explanation: Result
        let resultInfo = UILabel()
        resultInfo.text = "See the estimated area, the exact value (if available), and the error. Try changing n or the method to observe the effect on accuracy."
        resultInfo.font = .systemFont(ofSize: 13)
        resultInfo.textColor = .secondaryLabel
        resultInfo.numberOfLines = 0
        contentStack.addArrangedSubview(resultInfo)

        // Result
        resultLabel.font = .systemFont(ofSize: 18, weight: .medium)
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0
        contentStack.addArrangedSubview(resultLabel)
    }

    @objc private func functionChanged() {
        selectedFunctionIndex = functionSelector.selectedSegmentIndex
        switch selectedFunctionIndex {
        case 0:
            selectedFunction = { $0 * $0 }
            a = 0; b = 1
        case 1:
            selectedFunction = { sin($0) }
            a = 0; b = Double.pi
        case 2:
            selectedFunction = { exp($0) }
            a = 0; b = 1
        case 3:
            selectedFunction = { 1.0 / (1.0 + $0 * $0) }
            a = 0; b = 1
        default:
            selectedFunction = { $0 * $0 }
            a = 0; b = 1
        }
        aField.text = String(a)
        bField.text = String(b)
        updateGraphAndOutput()
    }

    @objc private func methodChanged() {
        updateGraphAndOutput()
    }

    @objc private func paramChanged() {
        a = Double(aField.text ?? "") ?? a
        b = Double(bField.text ?? "") ?? b
        updateGraphAndOutput()
    }

    @objc private func sliderChanged() {
        n = Int(nSlider.value)
        nLabel.text = "\(n)"
        updateGraphAndOutput()
    }

    private func updateGraphAndOutput() {
        let viewModel = NumericalIntegrationViewModel(f: selectedFunction, a: a, b: b, n: n)
        
        // Get polygons based on selected method
        let polygons: [[CGPoint]]
        switch methodSelector.selectedSegmentIndex {
        case 0:
            polygons = viewModel.trapezoidPoints()
        case 1:
            polygons = viewModel.simpsonPoints()
        case 2:
            polygons = viewModel.midpointPoints()
        default:
            polygons = viewModel.trapezoidPoints()
        }
        
        // Configure graph
        graphView.functionColor = .systemBlue
        graphView.fillColor = fillColorForFunction(index: selectedFunctionIndex)
        graphView.configure(function: selectedFunction, xRange: a...b, showGrid: true, gridStep: 0.5)
        graphView.fillPolygons(polygons)

        // Calculate area based on selected method
        let area: Double
        switch methodSelector.selectedSegmentIndex {
        case 0:
            area = viewModel.trapezoidalValue()
        case 1:
            area = viewModel.simpsonValue()
        case 2:
            area = viewModel.midpointValue()
        default:
            area = viewModel.trapezoidalValue()
        }
        
        let (trueValue, _) = analyticalIntegral()
        let error = (trueValue != nil) ? area - trueValue! : nil

        // Update result
        var resultText = String(format: "Area ≈ %.6f", area)
        if let trueValue = trueValue {
            resultText += String(format: "\nExact: %.6f", trueValue)
            if let error = error {
                resultText += String(format: "\nError: %.6f", error)
            }
        }
        resultLabel.text = resultText
    }
    
    private func fillColorForFunction(index: Int) -> UIColor {
        switch index {
        case 0: return UIColor.systemRed.withAlphaComponent(0.3)
        case 1: return UIColor.systemGreen.withAlphaComponent(0.3)
        case 2: return UIColor.systemBlue.withAlphaComponent(0.3)
        case 3: return UIColor.systemPurple.withAlphaComponent(0.3)
        default: return UIColor.systemGray.withAlphaComponent(0.3)
        }
    }
    
    private func analyticalIntegral() -> (Double?, String) {
        switch selectedFunctionIndex {
        case 0: // x²
            let exact = (pow(b, 3) - pow(a, 3)) / 3.0
            return (exact, "∫x²dx = x³/3")
        case 1: // sin(x)
            let exact = -cos(b) + cos(a)
            return (exact, "∫sin(x)dx = -cos(x)")
        case 2: // eˣ
            let exact = exp(b) - exp(a)
            return (exact, "∫eˣdx = eˣ")
        case 3: // 1/(1+x²)
            let exact = atan(b) - atan(a)
            return (exact, "∫1/(1+x²)dx = arctan(x)")
        default:
            return (nil, "")
        }
    }
} 