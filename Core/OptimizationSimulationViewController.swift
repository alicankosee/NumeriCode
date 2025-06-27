import UIKit

// Fixed function: f(x) = (x-3)² + 2
struct OptimizationFunction {
    static let f: (Double) -> Double = { x in
        pow(x - 3, 2) + 2
    }
    
    static let derivative: (Double) -> Double = { x in
        2 * (x - 3)
    }
    
    static let secondDerivative: (Double) -> Double = { _ in
        2.0
    }
}

struct OptimizationResult {
    let method: String
    let initialX: Double
    let iterations: Int
    let finalX: Double
    let finalValue: Double
    let steps: [Double]
    let stepValues: [Double]
    let hasConverged: Bool
    let convergenceMessage: String
    let usedIterations: Int
}

struct OptimizationViewModel {
    let method: String
    let iterations: Int
    let initialX: Double
    let learningRate: Double
    let epsilon: Double = 1e-4
    let intervalA: Double = -5.0
    let intervalB: Double = 10.0
    
    func optimize() -> OptimizationResult {
        switch method {
        case "Golden Section":
            return goldenSectionSearch()
        case "Newton's Method":
            return newtonMethod()
        case "Gradient Descent":
            return gradientDescent()
        default:
            return goldenSectionSearch()
        }
    }
    
    private func goldenSectionSearch() -> OptimizationResult {
        var a = intervalA
        var b = intervalB
        let phi = (sqrt(5.0) - 1) / 2
        var steps: [Double] = []
        var stepValues: [Double] = []
        
        for _ in 0..<iterations {
            let c = b - phi * (b - a)
            let d = a + phi * (b - a)
            
            steps.append(c)
            steps.append(d)
            stepValues.append(OptimizationFunction.f(c))
            stepValues.append(OptimizationFunction.f(d))
            
            if OptimizationFunction.f(c) < OptimizationFunction.f(d) {
                b = d
            } else {
                a = c
            }
        }
        
        let finalX = (a + b) / 2
        let finalValue = OptimizationFunction.f(finalX)
        
        return OptimizationResult(
            method: method,
            initialX: initialX,
            iterations: iterations,
            finalX: finalX,
            finalValue: finalValue,
            steps: steps,
            stepValues: stepValues,
            hasConverged: true,
            convergenceMessage: "✅ Minimum found at x = \(String(format: "%.4f", finalX)) with f(x) = \(String(format: "%.4f", finalValue))",
            usedIterations: iterations
        )
    }
    
    private func newtonMethod() -> OptimizationResult {
        var x = initialX
        var steps: [Double] = [x]
        var stepValues: [Double] = [OptimizationFunction.f(x)]
        var usedIterations = 1
        
        for i in 1..<iterations {
            let dfx = OptimizationFunction.derivative(x)
            let d2fx = OptimizationFunction.secondDerivative(x)
            
            if abs(d2fx) < epsilon {
                return OptimizationResult(
                    method: method,
                    initialX: initialX,
                    iterations: iterations,
                    finalX: x,
                    finalValue: OptimizationFunction.f(x),
                    steps: steps,
                    stepValues: stepValues,
                    hasConverged: false,
                    convergenceMessage: "The method did not converge within the given number of iterations. Try increasing the number of iterations, changing the starting point, or using a different method.",
                    usedIterations: iterations
                )
            }
            
            let xNew = x - dfx / d2fx
            let fNew = OptimizationFunction.f(xNew)
            
            steps.append(xNew)
            stepValues.append(fNew)
            usedIterations = i + 1
            
            // Check convergence
            if abs(xNew - x) < epsilon || abs(fNew - stepValues[stepValues.count - 2]) < epsilon {
                return OptimizationResult(
                    method: method,
                    initialX: initialX,
                    iterations: iterations,
                    finalX: xNew,
                    finalValue: fNew,
                    steps: steps,
                    stepValues: stepValues,
                    hasConverged: true,
                    convergenceMessage: "✅ Minimum found at x = \(String(format: "%.4f", xNew)) with f(x) = \(String(format: "%.4f", fNew))",
                    usedIterations: usedIterations
                )
            }
            
            x = xNew
        }
        
        return OptimizationResult(
            method: method,
            initialX: initialX,
            iterations: iterations,
            finalX: x,
            finalValue: OptimizationFunction.f(x),
            steps: steps,
            stepValues: stepValues,
            hasConverged: false,
            convergenceMessage: "The method did not converge within the given number of iterations. Try increasing the number of iterations, changing the starting point, or using a different method.",
            usedIterations: iterations
        )
    }
    
    private func gradientDescent() -> OptimizationResult {
        var x = initialX
        var steps: [Double] = [x]
        var stepValues: [Double] = [OptimizationFunction.f(x)]
        var usedIterations = 1
        
        for i in 1..<iterations {
            let dfx = OptimizationFunction.derivative(x)
            let xNew = x - learningRate * dfx
            let fNew = OptimizationFunction.f(xNew)
            
            steps.append(xNew)
            stepValues.append(fNew)
            usedIterations = i + 1
            
            // Check if step size is too large (oscillation)
            if fNew > stepValues[stepValues.count - 2] {
                return OptimizationResult(
                    method: method,
                    initialX: initialX,
                    iterations: iterations,
                    finalX: xNew,
                    finalValue: fNew,
                    steps: steps,
                    stepValues: stepValues,
                    hasConverged: false,
                    convergenceMessage: "Gradient descent failed: The learning rate is too large, causing the function value to increase. Try using a smaller learning rate.",
                    usedIterations: usedIterations
                )
            }
            
            // Check convergence
            if abs(xNew - x) < epsilon || abs(fNew - stepValues[stepValues.count - 2]) < epsilon {
                return OptimizationResult(
                    method: method,
                    initialX: initialX,
                    iterations: iterations,
                    finalX: xNew,
                    finalValue: fNew,
                    steps: steps,
                    stepValues: stepValues,
                    hasConverged: true,
                    convergenceMessage: "✅ Minimum found at x = \(String(format: "%.4f", xNew)) with f(x) = \(String(format: "%.4f", fNew))",
                    usedIterations: usedIterations
                )
            }
            
            x = xNew
        }
        
        return OptimizationResult(
            method: method,
            initialX: initialX,
            iterations: iterations,
            finalX: x,
            finalValue: OptimizationFunction.f(x),
            steps: steps,
            stepValues: stepValues,
            hasConverged: false,
            convergenceMessage: "The method did not converge within the given number of iterations. Try increasing the number of iterations, changing the starting point, or using a different method.",
            usedIterations: iterations
        )
    }
}

class OptimizationSimulationViewController: UIViewController {
    // UI Components
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    // Function display
    private let functionLabel = UILabel()
    
    // Controls
    private let methodSelector = UISegmentedControl(items: ["Golden Section", "Newton's Method", "Gradient Descent"])
    private let methodDescriptionLabel = UILabel()
    private let iterationsStepper = UIStepper()
    private let iterationsLabel = UILabel()
    private let initialXField = UITextField()
    private let learningRateSlider = UISlider()
    private let learningRateLabel = UILabel()
    private let solveButton = UIButton(type: .system)
    
    // Graph
    private let graphView = GraphView()
    
    // Results
    private let finalResultLabel = UILabel()
    private let stepsStack = UIStackView()
    
    // Math formula
    private let formulaLabel = UILabel()
    
    // Properties
    private var currentMethod: String = "Golden Section"
    private var iterations: Int = 10
    private var initialX: Double = 0.0
    private var learningRate: Double = 0.01
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Function Optimization"
        setupUI()
        updateMethodDescription()
    }
    
    private func setupUI() {
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup content stack
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        // Setup constraints
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
        
        // Function display
        functionLabel.text = "f(x) = (x - 3)² + 2"
        functionLabel.font = .systemFont(ofSize: 20, weight: .bold)
        functionLabel.textAlignment = .center
        functionLabel.textColor = .label
        functionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(functionLabel)
        
        // Method selector
        methodSelector.selectedSegmentIndex = 0
        methodSelector.addTarget(self, action: #selector(methodChanged), for: .valueChanged)
        methodSelector.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(methodSelector)
        
        // Method description
        methodDescriptionLabel.font = .systemFont(ofSize: 14)
        methodDescriptionLabel.textColor = .secondaryLabel
        methodDescriptionLabel.numberOfLines = 0
        methodDescriptionLabel.textAlignment = .center
        methodDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(methodDescriptionLabel)
        
        // Iterations control
        let iterationsContainer = UIStackView()
        iterationsContainer.axis = .horizontal
        iterationsContainer.spacing = 8
        iterationsContainer.alignment = .center
        iterationsContainer.distribution = .fillEqually
        
        iterationsLabel.text = "Iterations: \(iterations)"
        iterationsLabel.font = .systemFont(ofSize: 16)
        iterationsLabel.translatesAutoresizingMaskIntoConstraints = false
        iterationsContainer.addArrangedSubview(iterationsLabel)
        
        iterationsStepper.minimumValue = 1
        iterationsStepper.maximumValue = 50
        iterationsStepper.value = Double(iterations)
        iterationsStepper.addTarget(self, action: #selector(iterationsChanged), for: .valueChanged)
        iterationsStepper.translatesAutoresizingMaskIntoConstraints = false
        iterationsContainer.addArrangedSubview(iterationsStepper)
        
        contentStack.addArrangedSubview(iterationsContainer)
        
        // Initial X field
        let initialXContainer = UIStackView()
        initialXContainer.axis = .vertical
        initialXContainer.spacing = 8
        
        let initialXLabel = UILabel()
        initialXLabel.text = "Initial Guess (x₀):"
        initialXLabel.font = .systemFont(ofSize: 16)
        initialXContainer.addArrangedSubview(initialXLabel)
        
        initialXField.text = "0.0"
        initialXField.borderStyle = .roundedRect
        initialXField.keyboardType = .decimalPad
        initialXField.addTarget(self, action: #selector(initialXChanged), for: .editingChanged)
        initialXField.addTarget(self, action: #selector(initialXFieldDidBegin), for: .editingDidBegin)
        initialXContainer.addArrangedSubview(initialXField)
        
        contentStack.addArrangedSubview(initialXContainer)
        
        // Learning rate control (for Gradient Descent)
        let learningRateContainer = UIStackView()
        learningRateContainer.axis = .vertical
        learningRateContainer.spacing = 8
        learningRateContainer.isHidden = true
        
        learningRateLabel.text = "Learning Rate: 0.01"
        learningRateLabel.font = .systemFont(ofSize: 16)
        learningRateContainer.addArrangedSubview(learningRateLabel)
        
        learningRateSlider.minimumValue = 0.001
        learningRateSlider.maximumValue = 0.1
        learningRateSlider.value = Float(learningRate)
        learningRateSlider.addTarget(self, action: #selector(learningRateChanged), for: .valueChanged)
        learningRateContainer.addArrangedSubview(learningRateSlider)
        
        contentStack.addArrangedSubview(learningRateContainer)
        
        // Solve button
        solveButton.setTitle("Solve", for: .normal)
        solveButton.backgroundColor = .systemBlue
        solveButton.setTitleColor(.white, for: .normal)
        solveButton.layer.cornerRadius = 8
        solveButton.addTarget(self, action: #selector(solveButtonTapped), for: .touchUpInside)
        solveButton.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(solveButton)
        
        // Math formula
        formulaLabel.font = .systemFont(ofSize: 16, weight: .medium)
        formulaLabel.textAlignment = .center
        formulaLabel.numberOfLines = 0
        formulaLabel.textColor = .systemBlue
        formulaLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(formulaLabel)
        
        // Add educational info card
        let infoCard = createInfoCard(for: currentMethod)
        contentStack.addArrangedSubview(infoCard)
        
        // Graph
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        contentStack.addArrangedSubview(graphView)
        
        // Final result label
        finalResultLabel.font = .systemFont(ofSize: 16, weight: .bold)
        finalResultLabel.textAlignment = .center
        finalResultLabel.numberOfLines = 0
        finalResultLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(finalResultLabel)
        
        // Steps stack view
        stepsStack.axis = .vertical
        stepsStack.spacing = 8
        stepsStack.alignment = .fill
        stepsStack.backgroundColor = .systemGray6
        stepsStack.layer.cornerRadius = 8
        stepsStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        stepsStack.isLayoutMarginsRelativeArrangement = true
        stepsStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(stepsStack)
        
        updateMethodDescription()
    }
    
    private func updateMethodDescription() {
        switch currentMethod {
        case "Newton's Method":
            methodDescriptionLabel.text = "Uses derivatives to quickly find local minima using tangent lines. Most efficient when starting close to minimum.\n\nHow it works:\n1. Calculate f'(x) and f''(x)\n2. Move to x_new = x - f'(x)/f''(x)\n3. Repeat until convergence"
        case "Gradient Descent":
            methodDescriptionLabel.text = "Iteratively moves opposite to the gradient to minimize the function. Learning rate controls step size.\n\nHow it works:\n1. Calculate f'(x) (gradient)\n2. Move to x_new = x - α × f'(x)\n3. Repeat until convergence"
        case "Golden Section":
            methodDescriptionLabel.text = "Systematically narrows down the interval containing the minimum using the golden ratio. No derivatives needed.\n\nHow it works:\n1. Choose two points using golden ratio\n2. Compare function values\n3. Eliminate the worse half\n4. Repeat until interval is small"
        default:
            methodDescriptionLabel.text = ""
        }
    }
    
    @objc private func solveButtonTapped() {
        // Validate input
        guard let text = initialXField.text, !text.isEmpty,
              let _ = Double(text) else {
            showInputError()
            return
        }
        
        // Clear previous visualization
        graphView.drawPoints = []
        graphView.setStepNumbers([])
        graphView.startPoint = nil
        graphView.endPoint = nil
        graphView.highlightedPoint = nil
        
        // Clear results
        finalResultLabel.text = ""
        stepsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Update optimization with current values
        updateOptimization()
        
        // Scroll to bottom to show results
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let bottomOffset = CGPoint(
                x: 0,
                y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom
            )
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    private func showInputError() {
        // Show red border
        initialXField.layer.borderColor = UIColor.systemRed.cgColor
        initialXField.layer.borderWidth = 1
        
        // Shake animation
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0]
        initialXField.layer.add(animation, forKey: "shake")
        
        // Reset border after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.initialXField.layer.borderWidth = 0
        }
    }
    
    @objc private func methodChanged() {
        currentMethod = methodSelector.titleForSegment(at: methodSelector.selectedSegmentIndex) ?? "Golden Section"
        // Show/hide learning rate control for Gradient Descent
        if let learningRateContainer = contentStack.arrangedSubviews.first(where: { ($0 as? UIStackView)?.arrangedSubviews.contains(learningRateSlider) ?? false }) {
            learningRateContainer.isHidden = currentMethod != "Gradient Descent"
        }
        // Remove existing info card(s)
        contentStack.arrangedSubviews
            .filter { $0 is UIView && $0.backgroundColor == UIColor.systemBlue.withAlphaComponent(0.1) }
            .forEach { card in
                contentStack.removeArrangedSubview(card)
                card.removeFromSuperview()
            }
        // Add new info card
        let infoCard = createInfoCard(for: currentMethod)
        // Insert after formulaLabel (or at index 3 if order is fixed)
        if let formulaIndex = contentStack.arrangedSubviews.firstIndex(of: formulaLabel) {
            contentStack.insertArrangedSubview(infoCard, at: formulaIndex + 1)
        } else {
            contentStack.addArrangedSubview(infoCard)
        }
        // Clear previous results when method changes
        graphView.drawPoints = []
        graphView.setStepNumbers([])
        graphView.startPoint = nil
        graphView.endPoint = nil
        graphView.highlightedPoint = nil
        finalResultLabel.text = ""
        stepsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        updateMethodDescription()
        updateFormula()
    }
    
    @objc private func iterationsChanged() {
        iterations = Int(iterationsStepper.value)
        iterationsLabel.text = "Iterations: \(iterations)"
        updateOptimization()
    }
    
    @objc private func initialXChanged() {
        if let text = initialXField.text, let value = Double(text) {
            initialX = value
            updateOptimization()
        }
    }
    
    @objc private func initialXFieldDidBegin() {}
    
    @objc private func learningRateChanged() {
        learningRate = Double(learningRateSlider.value)
        learningRateLabel.text = String(format: "Learning Rate: %.3f", learningRate)
    }
    
    private func updateFormula() {
        switch currentMethod {
        case "Golden Section":
            formulaLabel.text = "Golden Ratio: φ = (√5 - 1) / 2 ≈ 0.618\nInterval shrinking using golden ratio"
        case "Newton's Method":
            formulaLabel.text = "x_{n+1} = x_n - f'(x_n) / f''(x_n)\nwhere f'(x) = 2(x-3), f''(x) = 2"
        case "Gradient Descent":
            formulaLabel.text = "x_{n+1} = x_n - α × f'(x_n)\nwhere α = 0.1, f'(x) = 2(x-3)"
        default:
            formulaLabel.text = ""
        }
    }
    
    private func updateOptimization() {
        let viewModel = OptimizationViewModel(
            method: currentMethod,
            iterations: iterations,
            initialX: initialX,
            learningRate: learningRate
        )
        let result = viewModel.optimize()
        
        // Configure graph with function
        graphView.configure(
            function: OptimizationFunction.f,
            xRange: -5...10,
            yRange: 0...15
        )
        
        // Update graph points
        let points = result.steps.enumerated().map { (index, x) in
            CGPoint(x: x, y: OptimizationFunction.f(x))
        }
        graphView.optimizationMethod = currentMethod
        graphView.drawPoints = points
        // Show step numbers
        graphView.setStepNumbers(Array(1...points.count))
        // Start point red, end point green, intermediate points orange
        graphView.startPoint = points.first
        graphView.endPoint = points.last
        graphView.highlightedPoint = points.last
        
        // Update final result label
        finalResultLabel.text = result.convergenceMessage
        finalResultLabel.textColor = result.hasConverged ? .systemGreen : .systemRed
        
        // Clear and update steps stack
        stepsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add step labels with better formatting
        for (index, (x, fx)) in zip(result.steps, result.stepValues).enumerated() {
            let stepContainer = UIView()
            stepContainer.backgroundColor = index % 2 == 0 ? UIColor.systemGray6.withAlphaComponent(0.3) : UIColor.clear
            stepContainer.layer.cornerRadius = 6
            
            let stepLabel = UILabel()
            stepLabel.text = String(format: "Step %d: x = %.4f, f(x) = %.4f", index + 1, x, fx)
            stepLabel.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
            stepLabel.textColor = .label
            stepLabel.numberOfLines = 0
            
            // Add improvement indicator
            if index > 0 {
                let prevFx = result.stepValues[index - 1]
                let improvement = prevFx - fx
                let improvementLabel = UILabel()
                improvementLabel.text = String(format: "Improvement: %.6f", improvement)
                improvementLabel.font = .systemFont(ofSize: 12, weight: .regular)
                if improvement > 0 {
                    improvementLabel.textColor = .systemGreen
                } else if improvement < 0 {
                    improvementLabel.textColor = .systemRed
                } else {
                    improvementLabel.textColor = .secondaryLabel
                }
                improvementLabel.numberOfLines = 0
                
                let stack = UIStackView(arrangedSubviews: [stepLabel, improvementLabel])
                stack.axis = .vertical
                stack.spacing = 4
                stepContainer.addSubview(stack)
                stack.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    stack.topAnchor.constraint(equalTo: stepContainer.topAnchor, constant: 8),
                    stack.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor, constant: 12),
                    stack.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor, constant: -12),
                    stack.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor, constant: -8)
                ])
            } else {
                stepContainer.addSubview(stepLabel)
                stepLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    stepLabel.topAnchor.constraint(equalTo: stepContainer.topAnchor, constant: 8),
                    stepLabel.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor, constant: 12),
                    stepLabel.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor, constant: -12),
                    stepLabel.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor, constant: -8)
                ])
            }
            
            stepsStack.addArrangedSubview(stepContainer)
        }
        
        // Update formula based on method
        switch currentMethod {
        case "Newton's Method":
            formulaLabel.text = "xₙ₊₁ = xₙ - f'(xₙ) / f''(xₙ)\nf'(x) = 2(x-3), f''(x) = 2"
        case "Gradient Descent":
            formulaLabel.text = "xₙ₊₁ = xₙ - α × f'(xₙ)\nα = 0.1, f'(x) = 2(x-3)"
        case "Golden Section":
            formulaLabel.text = "Golden Ratio: φ = (√5 - 1) / 2 ≈ 0.618\nInterval shrinking using golden ratio"
        default:
            formulaLabel.text = ""
        }
        
        // Redraw views
        DispatchQueue.main.async {
            self.graphView.setNeedsDisplay()
            self.finalResultLabel.setNeedsDisplay()
            self.stepsStack.setNeedsDisplay()
        }
    }
    
    private func createInfoCard(for method: String) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "Tips for \(method)"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .systemBlue
        
        let contentLabel = UILabel()
        contentLabel.numberOfLines = 0
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .label
        
        switch method {
        case "Newton's Method":
            contentLabel.text = "• Start close to the minimum for best results.\n• Requires both first and second derivatives.\n• Very fast convergence if conditions are right."
        case "Gradient Descent":
            contentLabel.text = "• Learning rate is crucial: too large may diverge, too small is slow.\n• Works for any differentiable function.\n• Try different learning rates if it doesn't converge."
        case "Golden Section":
            contentLabel.text = "• No derivatives needed.\n• Always converges within the interval.\n• Slower than derivative-based methods, but very robust."
        default:
            contentLabel.text = ""
        }
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stack.axis = .vertical
        stack.spacing = 8
        
        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
} 