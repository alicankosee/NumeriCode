import UIKit

// Sample ODE: dy/dx = -2y, y(0) = 1
// True solution: y = e^(-2x)
struct ODESolverViewModel {
    let method: String // "Euler", "RK4", "RK23"
    let f: (Double, Double) -> Double
    let x0: Double
    let y0: Double
    let xn: Double
    let n: Int
    
    // True solution for comparison
    let trueSolution: (Double) -> Double = { x in
        exp(-2 * x) // y = e^(-2x)
    }

    func solve() -> [(x: Double, y: Double)] {
        let h = (xn - x0) / Double(n)
        var x = x0
        var y = y0
        var result: [(Double, Double)] = [(x, y)]
        
        for _ in 0..<n {
            switch method {
            case "Euler":
                y += h * f(x, y)
            case "RK4":
                let k1 = h * f(x, y)
                let k2 = h * f(x + h/2, y + k1/2)
                let k3 = h * f(x + h/2, y + k2/2)
                let k4 = h * f(x + h, y + k3)
                y += (k1 + 2*k2 + 2*k3 + k4) / 6
            case "RK23":
                // RK2 (Heun's method)
                let k1 = h * f(x, y)
                let k2 = h * f(x + h, y + k1)
                y += (k1 + k2) / 2
            default:
                y += h * f(x, y)
            }
            x += h
            result.append((x, y))
        }
        return result
    }
    
    func getStepDetails() -> [String] {
        let h = (xn - x0) / Double(n)
        var x = x0
        var y = y0
        var details: [String] = []
        
        details.append("Step 0: x = \(String(format: "%.2f", x)), y = \(String(format: "%.4f", y))")
        
        for step in 1...n {
            switch method {
            case "Euler":
                y += h * f(x, y)
            case "RK4":
                let k1 = h * f(x, y)
                let k2 = h * f(x + h/2, y + k1/2)
                let k3 = h * f(x + h/2, y + k2/2)
                let k4 = h * f(x + h, y + k3)
                y += (k1 + 2*k2 + 2*k3 + k4) / 6
            case "RK23":
                let k1 = h * f(x, y)
                let k2 = h * f(x + h, y + k1)
                y += (k1 + k2) / 2
            default:
                y += h * f(x, y)
            }
            x += h
            details.append("Step \(step): x = \(String(format: "%.2f", x)), y = \(String(format: "%.4f", y))")
        }
        return details
    }
}

class ODESolverSimulationViewController: UIViewController {
    private lazy var graphView = GraphView()
    private let methodSelector = UISegmentedControl(items: ["Euler", "RK4", "RK23"])
    private let modeSelector = UISegmentedControl(items: ["Single Method", "Compare Methods"])
    private let methodInfoCard = UIView()
    private let methodInfoIcon = UIImageView()
    private let methodInfoTitle = UILabel()
    private let methodInfoDesc = UILabel()
    private let methodInfoStripe = UIView()
    private let hSlider = UISlider()
    private let hValueLabel = UILabel()
    private let x0Slider = UISlider()
    private let y0Slider = UISlider()
    private let xnSlider = UISlider()
    private let x0ValueLabel = UILabel()
    private let y0ValueLabel = UILabel()
    private let xnValueLabel = UILabel()
    private let stepCardView = UIView()
    private let stepCardLabel = UILabel()
    private let prevStepButton = UIButton(type: .system)
    private let nextStepButton = UIButton(type: .system)
    private let stepIndicatorLabel = UILabel()
    
    private var method: String = "Euler"
    private var n: Int = 20
    private var x0: Double = 0
    private var y0: Double = 1
    private var xn: Double = 2
    
    // Sample ODE: dy/dx = -2y, y(0) = 1
    private var f: (Double, Double) -> Double = { _, y in -2 * y }

    private var currentStepIndex: Int = 0
    private var stepDetails: [String] = []
    private var stepCount: Int { stepDetails.count }
    private var isCompareMode: Bool { modeSelector.selectedSegmentIndex == 1 }

    private let formulaLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "ODE Solver"
        setupUI()
        updateFormula()
        updateSimulation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSimulation()
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Formula Label with modern styling
        formulaLabel.font = .systemFont(ofSize: 16, weight: .medium)
        formulaLabel.textColor = .label
        formulaLabel.numberOfLines = 0
        formulaLabel.textAlignment = .center
        formulaLabel.backgroundColor = UIColor.systemGray6
        formulaLabel.layer.cornerRadius = 8
        formulaLabel.layer.masksToBounds = true
        formulaLabel.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        contentStack.addArrangedSubview(formulaLabel)
        
        // Method and Mode Selectors in a horizontal stack
        let selectorStack = UIStackView()
        selectorStack.axis = .vertical
        selectorStack.spacing = 12
        
        methodSelector.selectedSegmentIndex = 0
        methodSelector.backgroundColor = .systemBackground
        methodSelector.selectedSegmentTintColor = .systemBlue
        methodSelector.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        methodSelector.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        methodSelector.addTarget(self, action: #selector(methodChanged), for: .valueChanged)
        
        modeSelector.selectedSegmentIndex = 0
        modeSelector.backgroundColor = .systemBackground
        modeSelector.selectedSegmentTintColor = .systemBlue
        modeSelector.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        modeSelector.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        modeSelector.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        
        selectorStack.addArrangedSubview(methodSelector)
        selectorStack.addArrangedSubview(modeSelector)
        contentStack.addArrangedSubview(selectorStack)
        
        // Parameters Stack
        let parametersCard = UIView()
        parametersCard.backgroundColor = .systemBackground
        parametersCard.layer.cornerRadius = 12
        parametersCard.layer.shadowColor = UIColor.black.cgColor
        parametersCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        parametersCard.layer.shadowRadius = 4
        parametersCard.layer.shadowOpacity = 0.1
        
        let parametersStack = UIStackView()
        parametersStack.axis = .vertical
        parametersStack.spacing = 16
        parametersStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        parametersStack.isLayoutMarginsRelativeArrangement = true
        
        // Add parameter sliders
        let sliderConfigs: [(String, UISlider, UILabel, Float, Float, Float)] = [
            ("Initial x (x₀)", x0Slider, x0ValueLabel, 0, 5, Float(x0)),
            ("Initial y (y₀)", y0Slider, y0ValueLabel, -2, 2, Float(y0)),
            ("Final x (xₙ)", xnSlider, xnValueLabel, 0.5, 10, Float(xn)),
            ("Step size (h)", hSlider, hValueLabel, 0.01, 1.0, Float((xn - x0) / Double(n)))
        ]
        
        for (title, slider, label, min, max, value) in sliderConfigs {
            let stack = createParameterStack(title: title, slider: slider, valueLabel: label)
            slider.minimumValue = min
            slider.maximumValue = max
            slider.value = value
            slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
            label.text = String(format: "%.2f", value)
            parametersStack.addArrangedSubview(stack)
        }
        
        parametersCard.addSubview(parametersStack)
        parametersStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            parametersStack.topAnchor.constraint(equalTo: parametersCard.topAnchor),
            parametersStack.leadingAnchor.constraint(equalTo: parametersCard.leadingAnchor),
            parametersStack.trailingAnchor.constraint(equalTo: parametersCard.trailingAnchor),
            parametersStack.bottomAnchor.constraint(equalTo: parametersCard.bottomAnchor)
        ])
        
        contentStack.addArrangedSubview(parametersCard)
        
        // Graph View with modern styling
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.layer.cornerRadius = 12
        graphView.layer.masksToBounds = true
        graphView.backgroundColor = .systemBackground
        graphView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        contentStack.addArrangedSubview(graphView)
        
        // Step Navigation UI
        setupStepNavigationUI(in: contentStack)
        
        // Method Info Card
        setupMethodInfoCard(in: contentStack)
        
        // Initial UI update
        updateMethodInfoCard()
        updateSimulation()
    }
    
    private func createParameterStack(title: String, slider: UISlider, valueLabel: UILabel) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        
        let sliderStack = UIStackView()
        sliderStack.axis = .horizontal
        sliderStack.spacing = 12
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        valueLabel.textAlignment = .right
        valueLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        sliderStack.addArrangedSubview(slider)
        sliderStack.addArrangedSubview(valueLabel)
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(sliderStack)
        
        return stack
    }
    
    private func setupStepNavigationUI(in contentStack: UIStackView) {
        // Step Card
        stepCardView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.7)
        stepCardView.layer.cornerRadius = 12
        stepCardView.layer.masksToBounds = true
        
        stepCardLabel.font = .systemFont(ofSize: 14)
        stepCardLabel.textColor = .label
        stepCardLabel.numberOfLines = 0
        stepCardLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stepCardView.addSubview(stepCardLabel)
        NSLayoutConstraint.activate([
            stepCardLabel.topAnchor.constraint(equalTo: stepCardView.topAnchor, constant: 12),
            stepCardLabel.leadingAnchor.constraint(equalTo: stepCardView.leadingAnchor, constant: 16),
            stepCardLabel.trailingAnchor.constraint(equalTo: stepCardView.trailingAnchor, constant: -16),
            stepCardLabel.bottomAnchor.constraint(equalTo: stepCardView.bottomAnchor, constant: -12)
        ])
        
        // Step Controls
        let stepControlStack = UIStackView()
        stepControlStack.axis = .horizontal
        stepControlStack.spacing = 16
        stepControlStack.alignment = .center
        stepControlStack.distribution = .equalCentering
        
        // Style the buttons
        for (button, title) in [(prevStepButton, "← Previous"), (nextStepButton, "Next →")] {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            button.layer.cornerRadius = 8
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        }
        
        prevStepButton.addTarget(self, action: #selector(prevStepTapped), for: .touchUpInside)
        nextStepButton.addTarget(self, action: #selector(nextStepTapped), for: .touchUpInside)
        
        stepIndicatorLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        stepIndicatorLabel.textColor = .secondaryLabel
        stepIndicatorLabel.textAlignment = .center
        
        stepControlStack.addArrangedSubview(prevStepButton)
        stepControlStack.addArrangedSubview(stepIndicatorLabel)
        stepControlStack.addArrangedSubview(nextStepButton)
        
        contentStack.addArrangedSubview(stepCardView)
        contentStack.addArrangedSubview(stepControlStack)
    }
    
    @objc private func methodChanged() {
        let methods = ["Euler", "RK4", "RK23"]
        method = methods[methodSelector.selectedSegmentIndex]
        updateFormula()
        updateSimulation()
    }
    
    @objc private func modeChanged() {
        currentStepIndex = 0
        updateSimulation()
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        // Update values
        if sender == x0Slider {
            x0 = Double(sender.value)
            x0ValueLabel.text = String(format: "%.2f", x0)
            // Ensure xn > x0
            if xn <= x0 {
                xn = x0 + 0.1
                xnSlider.value = Float(xn)
                xnValueLabel.text = String(format: "%.2f", xn)
            }
        } else if sender == y0Slider {
            y0 = Double(sender.value)
            y0ValueLabel.text = String(format: "%.2f", y0)
        } else if sender == xnSlider {
            xn = Double(sender.value)
            xnValueLabel.text = String(format: "%.2f", xn)
            // Ensure xn > x0
            if xn <= x0 {
                x0 = xn - 0.1
                x0Slider.value = Float(x0)
                x0ValueLabel.text = String(format: "%.2f", x0)
            }
        } else if sender == hSlider {
            let h = Double(sender.value)
            hValueLabel.text = String(format: "%.3f", h)
            // Update n based on h
            let interval = xn - x0
            n = max(1, Int(round(interval / h)))
        }
        
        // Synchronize h and n
        let interval = xn - x0
        let currentH = interval / Double(n)
        hSlider.value = Float(currentH)
        hValueLabel.text = String(format: "%.3f", currentH)
        
        // Reset step index when parameters change
        currentStepIndex = 0
        
        // Update simulation
        updateSimulation()
    }
    
    private func updateFormula() {
        switch method {
        case "Euler":
            formulaLabel.text = "Euler Method: y_{n+1} = y_n + h f(x_n, y_n)"
        case "RK4":
            formulaLabel.text = "RK4 Method: y_{n+1} = y_n + (h/6)(k₁ + 2k₂ + 2k₃ + k₄)"
        case "RK23":
            formulaLabel.text = "RK2 (Heun) Method: y_{n+1} = y_n + (h/2)(k₁ + k₂)"
        default:
            formulaLabel.text = "ODE: dy/dx = -2y, y(0) = 1"
        }
    }
    
    private func updateSimulation() {
        if isCompareMode {
            // Compare Methods: Show graph with legend
            let methods = ["Euler", "RK4", "RK23"]
            let colors: [UIColor] = [
                .systemBlue,
                .systemGreen,
                .systemOrange,
                UIColor.systemRed.withAlphaComponent(0.7)
            ]
            let legendLabels = ["Euler Method", "RK4 Method", "RK2/3 Method", "True Solution"]
            
            // Calculate y-range dynamically
            var allPoints: [Double] = []
            var functions: [(Double) -> Double] = []
            
            // Collect all points for y-range calculation
            for method in methods {
                let viewModel = ODESolverViewModel(method: method, f: f, x0: x0, y0: y0, xn: xn, n: n)
                let points = viewModel.solve()
                allPoints.append(contentsOf: points.map { $0.y })
                
                let interp: (Double) -> Double = { x in
                    guard let i = points.firstIndex(where: { $0.x >= x }), i > 0 else {
                        return points.first?.y ?? 0
                    }
                    let p0 = points[i-1], p1 = points[i]
                    let t = (x - p0.x) / (p1.x - p0.x)
                    return p0.y + t * (p1.y - p0.y)
                }
                functions.append(interp)
            }
            
            // Add true solution
            let trueSolution: (Double) -> Double = { x in exp(-2 * x) }
            functions.append(trueSolution)
            
            // Calculate y-range with padding
            let minY = (allPoints.min() ?? 0) - 0.1
            let maxY = (allPoints.max() ?? 1) + 0.1
            let yRange = minY...maxY
            
            // Configure graph
            graphView.isHidden = false
            graphView.showLegend = true
            graphView.legendLabels = legendLabels
            graphView.configureWithMultipleFunctions(
                functions: functions,
                xRange: x0...xn,
                yRange: yRange,
                colors: colors
            )
            
            // Hide step-related UI
            stepCardView.isHidden = true
            prevStepButton.isHidden = true
            nextStepButton.isHidden = true
            stepIndicatorLabel.isHidden = true
            
            // Show method info with comparison text
            methodInfoCard.isHidden = false
            methodInfoTitle.text = "Method Comparison"
            methodInfoDesc.text = "Compare accuracy and behavior of different numerical methods"
            methodInfoIcon.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
            methodInfoIcon.tintColor = .systemIndigo
            methodInfoStripe.backgroundColor = .systemIndigo
            
        } else {
            // Single Method: Show step-by-step solution
            let viewModel = ODESolverViewModel(method: method, f: f, x0: x0, y0: y0, xn: xn, n: n)
            let numericalPoints = viewModel.solve()
            let points = numericalPoints.map { CGPoint(x: $0.x, y: $0.y) }
            
            // Calculate y-range dynamically
            let yValues = points.map { Double($0.y) }
            let minY = (yValues.min() ?? 0) - 0.1
            let maxY = (yValues.max() ?? 1) + 0.1
            let yRange = minY...maxY
            
            let numericalFunction: (Double) -> Double = { x in
                guard let i = points.firstIndex(where: { $0.x >= x }), i > 0 else {
                    return points.first.map { Double($0.y) } ?? 0
                }
                let p0 = points[i-1], p1 = points[i]
                let t = (x - p0.x) / (p1.x - p0.x)
                return Double(p0.y) + t * (Double(p1.y) - Double(p0.y))
            }
            
            let trueFunction: (Double) -> Double = { x in exp(-2 * x) }
            
            // Configure graph for single method
            graphView.isHidden = false
            graphView.showLegend = true
            graphView.legendLabels = ["\(method) Method", "True Solution"]
            graphView.configureWithSecondaryFunction(
                primaryFunction: numericalFunction,
                secondaryFunction: trueFunction,
                xRange: x0...xn,
                yRange: yRange,
                points: points,
                secondaryColor: UIColor.systemRed.withAlphaComponent(0.7),
                secondaryStyle: .dashed
            )
            
            // Show step-related UI
            stepDetails = viewModel.getStepDetails()
            if currentStepIndex >= stepDetails.count { currentStepIndex = 0 }
            updateStepCard()
            stepCardView.isHidden = false
            prevStepButton.isHidden = false
            nextStepButton.isHidden = false
            stepIndicatorLabel.isHidden = false
            methodInfoCard.isHidden = false
            updateMethodInfoCard()
        }
        
        // Invalid data check
        if n < 1 || xn <= x0 {
            graphView.isHidden = false
            graphView.showLegend = false
            graphView.showNoDataOverlay(message: "⚠️ No valid solution to display.\nPlease check your parameters.")
            stepCardView.isHidden = true
            prevStepButton.isHidden = true
            nextStepButton.isHidden = true
            stepIndicatorLabel.isHidden = true
            methodInfoCard.isHidden = false
            return
        }
    }
    
    private func updateStepCard() {
        guard !stepDetails.isEmpty else {
            stepCardLabel.text = "No steps available."
            stepIndicatorLabel.text = ""
            prevStepButton.isEnabled = false
            nextStepButton.isEnabled = false
            graphView.highlightedPoint = nil
            graphView.setNeedsDisplay()
            return
        }
        
        let viewModel = ODESolverViewModel(method: method, f: f, x0: x0, y0: y0, xn: xn, n: n)
        let numericalPoints = viewModel.solve()
        let pt = currentStepIndex < numericalPoints.count ? numericalPoints[currentStepIndex] : (x: 0.0, y: 0.0)
        
        // Enhanced step explanation
        let methodExplanation = getMethodStepExplanation(method: method, x: pt.x, y: pt.y)
        let stepText = """
        Step \(currentStepIndex + 1) of \(stepCount)
        Current point: (x = \(String(format: "%.3f", pt.x)), y = \(String(format: "%.5f", pt.y)))
        \(methodExplanation)
        """
        
        stepCardLabel.text = stepText
        stepIndicatorLabel.text = "Step \(currentStepIndex + 1) / \(stepCount)"
        
        // Update button states
        prevStepButton.isEnabled = currentStepIndex > 0
        nextStepButton.isEnabled = currentStepIndex < stepCount - 1
        
        // Style buttons based on state
        prevStepButton.alpha = prevStepButton.isEnabled ? 1.0 : 0.5
        nextStepButton.alpha = nextStepButton.isEnabled ? 1.0 : 0.5
        
        // Update graph highlight
        if currentStepIndex < numericalPoints.count {
            graphView.highlightedPoint = CGPoint(x: pt.x, y: pt.y)
            graphView.highlightRadius = 6.0
            graphView.highlightColor = UIColor.systemBlue.withAlphaComponent(0.8)
        } else {
            graphView.highlightedPoint = nil
        }
        graphView.setNeedsDisplay()
    }
    
    private func getMethodStepExplanation(method: String, x: Double, y: Double) -> String {
        let h = (xn - x0) / Double(n)
        switch method {
        case "Euler":
            let slope = f(x, y)
            return "Euler step: Using slope f(\(String(format: "%.3f", x)), \(String(format: "%.3f", y))) = \(String(format: "%.3f", slope))"
        case "RK4":
            let k1 = h * f(x, y)
            let k2 = h * f(x + h/2, y + k1/2)
            let k3 = h * f(x + h/2, y + k2/2)
            let k4 = h * f(x + h, y + k3)
            return "RK4 step: Using weighted average of 4 slopes\nk₁=\(String(format: "%.3f", k1)), k₂=\(String(format: "%.3f", k2))"
        case "RK23":
            let k1 = h * f(x, y)
            let k2 = h * f(x + h, y + k1)
            return "Heun step: Average of slopes at start and end\nk₁=\(String(format: "%.3f", k1)), k₂=\(String(format: "%.3f", k2))"
        default:
            return "Using selected numerical method"
        }
    }
    
    @objc private func prevStepTapped() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
            updateStepCard()
        }
    }
    
    @objc private func nextStepTapped() {
        if currentStepIndex < stepCount - 1 {
            currentStepIndex += 1
            updateStepCard()
        }
    }
    
    // Converts technical step string to a student-friendly English explanation
    private func englishStepDescription(_ step: String) -> String {
        if step.contains("Euler") {
            return "Euler step: y_{n+1} = y_n + h f(x_n, y_n)"
        }
        if step.contains("RK4") {
            return "RK4 step: y_{n+1} = y_n + (h/6)(k₁ + 2k₂ + 2k₃ + k₄)"
        }
        if step.contains("RK2") || step.contains("Heun") {
            return "RK2 (Heun) step: y_{n+1} = y_n + (h/2)(k₁ + k₂)"
        }
        if step.contains("Step") {
            return step
        }
        return step
    }
    
    private func updateMethodInfoCard() {
        switch method {
        case "Euler":
            methodInfoTitle.text = "Euler's Method"
            methodInfoDesc.text = "First-order method using local linear approximation. Simple but requires small steps for accuracy."
            methodInfoIcon.image = UIImage(systemName: "arrow.right.circle.fill")
            methodInfoIcon.tintColor = .systemBlue
            methodInfoStripe.backgroundColor = .systemBlue
        case "RK4":
            methodInfoTitle.text = "Runge-Kutta 4 (RK4)"
            methodInfoDesc.text = "Fourth-order method using weighted average of four slopes. Excellent balance of accuracy and efficiency."
            methodInfoIcon.image = UIImage(systemName: "circle.grid.cross.fill")
            methodInfoIcon.tintColor = .systemGreen
            methodInfoStripe.backgroundColor = .systemGreen
        case "RK23":
            methodInfoTitle.text = "Heun's Method (RK2/3)"
            methodInfoDesc.text = "Second-order predictor-corrector method. Good compromise between Euler and RK4."
            methodInfoIcon.image = UIImage(systemName: "arrow.triangle.branch")
            methodInfoIcon.tintColor = .systemOrange
            methodInfoStripe.backgroundColor = .systemOrange
        default:
            methodInfoTitle.text = "ODE Method"
            methodInfoDesc.text = "Select a method to see its description"
            methodInfoIcon.image = UIImage(systemName: "questionmark.circle")
            methodInfoIcon.tintColor = .systemGray
            methodInfoStripe.backgroundColor = .systemGray
        }
        
        // Update card styling
        methodInfoTitle.font = .systemFont(ofSize: 16, weight: .bold)
        methodInfoDesc.font = .systemFont(ofSize: 14)
        methodInfoDesc.numberOfLines = 2
        methodInfoCard.layer.shadowColor = UIColor.black.cgColor
        methodInfoCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        methodInfoCard.layer.shadowRadius = 4
        methodInfoCard.layer.shadowOpacity = 0.1
    }
    
    private func setupMethodInfoCard(in contentStack: UIStackView) {
        methodInfoCard.backgroundColor = UIColor.systemGray6
        methodInfoCard.layer.cornerRadius = 12
        methodInfoCard.layer.masksToBounds = true
        methodInfoCard.translatesAutoresizingMaskIntoConstraints = false
        methodInfoCard.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        // Stripe
        methodInfoStripe.translatesAutoresizingMaskIntoConstraints = false
        methodInfoCard.addSubview(methodInfoStripe)
        NSLayoutConstraint.activate([
            methodInfoStripe.leadingAnchor.constraint(equalTo: methodInfoCard.leadingAnchor),
            methodInfoStripe.topAnchor.constraint(equalTo: methodInfoCard.topAnchor),
            methodInfoStripe.bottomAnchor.constraint(equalTo: methodInfoCard.bottomAnchor),
            methodInfoStripe.widthAnchor.constraint(equalToConstant: 6)
        ])
        
        // Icon
        methodInfoIcon.translatesAutoresizingMaskIntoConstraints = false
        methodInfoIcon.contentMode = .scaleAspectFit
        methodInfoIcon.tintColor = .systemBlue
        methodInfoCard.addSubview(methodInfoIcon)
        NSLayoutConstraint.activate([
            methodInfoIcon.leadingAnchor.constraint(equalTo: methodInfoStripe.trailingAnchor, constant: 12),
            methodInfoIcon.centerYAnchor.constraint(equalTo: methodInfoCard.centerYAnchor),
            methodInfoIcon.widthAnchor.constraint(equalToConstant: 32),
            methodInfoIcon.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Title
        methodInfoTitle.font = .systemFont(ofSize: 16, weight: .bold)
        methodInfoTitle.textColor = .label
        methodInfoTitle.translatesAutoresizingMaskIntoConstraints = false
        methodInfoCard.addSubview(methodInfoTitle)
        NSLayoutConstraint.activate([
            methodInfoTitle.leadingAnchor.constraint(equalTo: methodInfoIcon.trailingAnchor, constant: 12),
            methodInfoTitle.topAnchor.constraint(equalTo: methodInfoCard.topAnchor, constant: 16),
            methodInfoTitle.trailingAnchor.constraint(equalTo: methodInfoCard.trailingAnchor, constant: -8)
        ])
        
        // Description
        methodInfoDesc.font = .systemFont(ofSize: 14)
        methodInfoDesc.textColor = .secondaryLabel
        methodInfoDesc.numberOfLines = 0
        methodInfoDesc.translatesAutoresizingMaskIntoConstraints = false
        methodInfoCard.addSubview(methodInfoDesc)
        NSLayoutConstraint.activate([
            methodInfoDesc.leadingAnchor.constraint(equalTo: methodInfoIcon.trailingAnchor, constant: 12),
            methodInfoDesc.topAnchor.constraint(equalTo: methodInfoTitle.bottomAnchor, constant: 4),
            methodInfoDesc.trailingAnchor.constraint(equalTo: methodInfoCard.trailingAnchor, constant: -8),
            methodInfoDesc.bottomAnchor.constraint(equalTo: methodInfoCard.bottomAnchor, constant: -16)
        ])
        
        methodInfoCard.isHidden = false
        contentStack.addArrangedSubview(methodInfoCard)
    }
} 