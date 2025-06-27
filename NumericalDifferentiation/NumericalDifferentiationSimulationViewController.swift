import UIKit

class NumericalDifferentiationSimulationViewController: UIViewController {
    // UI Components
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let graphView = GraphView()
    private let diffLabel = UILabel()
    private let errorLabel = UILabel()
    private let methodDescriptionLabel = UILabel()
    
    private let functionSelector = UISegmentedControl(items: ["sin(x)", "x²", "eˣ"])
    private let methodSelector = UISegmentedControl(items: ["Forward", "Backward", "Central"])
    
    private let inputStack = UIStackView()
    private let xField = UITextField()
    private let hField = UITextField()
    
    private let errorGraphView = GraphView()
    private let convergenceGraphView = GraphView()
    private let optimizeButton = UIButton(type: .system)
    private let analysisSegmentControl = UISegmentedControl(items: ["Error", "Convergence"])
    
    // Properties
    private var selectedFunction: (Double) -> Double = { sin($0) }
    private var x: Double = 2.0
    private var h: Double = 0.1
    private var method: String = "Forward"
    
    private var isAnimating = false
    private var animationTimer: Timer?
    private var currentAnimationStep = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Numerical Differentiation"
        setupUI()
        updateGraph()
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
        
        // Function selector
        let functionLabel = UILabel()
        functionLabel.text = "Select Function:"
        functionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentStack.addArrangedSubview(functionLabel)
        
        functionSelector.selectedSegmentIndex = 0
        functionSelector.addTarget(self, action: #selector(functionChanged), for: .valueChanged)
        contentStack.addArrangedSubview(functionSelector)
        
        // Method selector
        let methodLabel = UILabel()
        methodLabel.text = "Differentiation Method:"
        methodLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentStack.addArrangedSubview(methodLabel)
        
        methodSelector.selectedSegmentIndex = 0
        methodSelector.addTarget(self, action: #selector(methodChanged), for: .valueChanged)
        contentStack.addArrangedSubview(methodSelector)
        
        // Method description
        methodDescriptionLabel.font = .systemFont(ofSize: 14)
        methodDescriptionLabel.textColor = .secondaryLabel
        methodDescriptionLabel.numberOfLines = 0
        methodDescriptionLabel.textAlignment = .center
        contentStack.addArrangedSubview(methodDescriptionLabel)
        
        // Input fields
        let inputContainer = UIStackView()
        inputContainer.axis = .horizontal
        inputContainer.spacing = 16
        inputContainer.distribution = .fillEqually
        
        // x₀ input
        let xContainer = UIStackView()
        xContainer.axis = .vertical
        xContainer.spacing = 8
        
        let xLabel = UILabel()
        xLabel.text = "Point (x₀):"
        xLabel.font = .systemFont(ofSize: 14)
        xContainer.addArrangedSubview(xLabel)
        
        xField.placeholder = "x₀"
        xField.borderStyle = .roundedRect
        xField.keyboardType = .decimalPad
        xField.text = String(x)
        xField.addTarget(self, action: #selector(paramChanged), for: .editingChanged)
        xContainer.addArrangedSubview(xField)
        
        inputContainer.addArrangedSubview(xContainer)
        
        // h input
        let hContainer = UIStackView()
        hContainer.axis = .vertical
        hContainer.spacing = 8
        
        let hLabel = UILabel()
        hLabel.text = "Step Size (h):"
        hLabel.font = .systemFont(ofSize: 14)
        hContainer.addArrangedSubview(hLabel)
        
        hField.placeholder = "h"
        hField.borderStyle = .roundedRect
        hField.keyboardType = .decimalPad
        hField.text = String(h)
        hField.addTarget(self, action: #selector(paramChanged), for: .editingChanged)
        hContainer.addArrangedSubview(hField)
        
        inputContainer.addArrangedSubview(hContainer)
        
        contentStack.addArrangedSubview(inputContainer)
        
        // Main graph title
        let mainGraphTitle = UILabel()
        mainGraphTitle.text = "Function and Tangent Line Visualization"
        mainGraphTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        mainGraphTitle.textAlignment = .center
        contentStack.addArrangedSubview(mainGraphTitle)
        
        // Main graph description
        let mainGraphDesc = UILabel()
        mainGraphDesc.text = "Blue: f(x)   |   Red: Tangent at x₀   |   Dots: Used points"
        mainGraphDesc.font = .systemFont(ofSize: 13)
        mainGraphDesc.textColor = .secondaryLabel
        mainGraphDesc.textAlignment = .center
        contentStack.addArrangedSubview(mainGraphDesc)
        
        // Graph
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        graphView.xAxisLabel = "x"
        graphView.yAxisLabel = "f(x)"
        graphView.showLegend = false
        contentStack.addArrangedSubview(graphView)
        
        // Results
        diffLabel.font = .systemFont(ofSize: 16, weight: .medium)
        diffLabel.textAlignment = .center
        diffLabel.numberOfLines = 0
        contentStack.addArrangedSubview(diffLabel)
        
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.textAlignment = .center
        errorLabel.textColor = .secondaryLabel
        errorLabel.numberOfLines = 0
        contentStack.addArrangedSubview(errorLabel)
        
        // Analysis controls
        let analysisLabel = UILabel()
        analysisLabel.text = "Analysis Type:"
        analysisLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentStack.addArrangedSubview(analysisLabel)
        
        analysisSegmentControl.selectedSegmentIndex = 0
        analysisSegmentControl.addTarget(self, action: #selector(analysisTypeChanged), for: .valueChanged)
        contentStack.addArrangedSubview(analysisSegmentControl)
        
        // Optimize button
        optimizeButton.setTitle("Optimize Step Size", for: .normal)
        optimizeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        optimizeButton.backgroundColor = .systemBlue
        optimizeButton.setTitleColor(.white, for: .normal)
        optimizeButton.layer.cornerRadius = 8
        optimizeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        optimizeButton.addTarget(self, action: #selector(optimizeStepSize), for: .touchUpInside)
        contentStack.addArrangedSubview(optimizeButton)
        
        // Error graph
        let errorGraphTitle = UILabel()
        errorGraphTitle.text = "Step Size - Error Analysis (Log Scale)"
        errorGraphTitle.font = .systemFont(ofSize: 14, weight: .medium)
        errorGraphTitle.textAlignment = .center
        contentStack.addArrangedSubview(errorGraphTitle)
        
        let errorGraphSubtitle = UILabel()
        errorGraphSubtitle.text = "X: log₁₀(h) | Y: log₁₀(|Exact - Approximate|)"
        errorGraphSubtitle.font = .systemFont(ofSize: 12)
        errorGraphSubtitle.textColor = .secondaryLabel
        errorGraphSubtitle.textAlignment = .center
        contentStack.addArrangedSubview(errorGraphSubtitle)
        
        errorGraphView.translatesAutoresizingMaskIntoConstraints = false
        errorGraphView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        contentStack.addArrangedSubview(errorGraphView)
        
        // Convergence graph
        let convergenceGraphTitle = UILabel()
        convergenceGraphTitle.text = "Convergence Analysis (Log Scale)"
        convergenceGraphTitle.font = .systemFont(ofSize: 14, weight: .medium)
        convergenceGraphTitle.textAlignment = .center
        contentStack.addArrangedSubview(convergenceGraphTitle)
        
        let convergenceGraphSubtitle = UILabel()
        convergenceGraphSubtitle.text = "X: Iteration Count | Y: log₁₀(|Error|)"
        convergenceGraphSubtitle.font = .systemFont(ofSize: 12)
        convergenceGraphSubtitle.textColor = .secondaryLabel
        convergenceGraphSubtitle.textAlignment = .center
        contentStack.addArrangedSubview(convergenceGraphSubtitle)
        
        convergenceGraphView.translatesAutoresizingMaskIntoConstraints = false
        convergenceGraphView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        convergenceGraphView.isHidden = true
        contentStack.addArrangedSubview(convergenceGraphView)
        
        updateMethodDescription()
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
        if let newX = Double(xField.text ?? ""), !newX.isNaN && !newX.isInfinite {
            x = newX
        }
        if let newH = Double(hField.text ?? ""), !newH.isNaN && !newH.isInfinite && newH > 0 {
            h = newH
        }
        updateGraph()
    }

    @objc private func methodChanged() {
        let methods = ["Forward", "Backward", "Central"]
        method = methods[methodSelector.selectedSegmentIndex]
        updateMethodDescription()
        updateGraph()
    }
    
    @objc private func analysisTypeChanged() {
        errorGraphView.isHidden = analysisSegmentControl.selectedSegmentIndex == 1
        convergenceGraphView.isHidden = analysisSegmentControl.selectedSegmentIndex == 0
        updateAnalysisGraphs()
    }
    
    @objc private func optimizeStepSize() {
        let viewModel = NumericalDiffViewModel(f: selectedFunction, method: method, h: h, x: x)
        let optimalH = viewModel.findOptimalStepSize()
        
        // Animate the transition
        let startH = h
        let steps = 10
        currentAnimationStep = 0
        
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            
            self.currentAnimationStep += 1
            let progress = Double(self.currentAnimationStep) / Double(steps)
            let newH = startH + (optimalH - startH) * progress
            
            self.h = newH
            self.hField.text = String(format: "%.6f", newH)
            self.updateGraph()
            
            if self.currentAnimationStep >= steps {
                timer.invalidate()
                self.animationTimer = nil
            }
        }
    }
    
    private func updateMethodDescription() {
        switch method {
        case "Forward":
            methodDescriptionLabel.text = "Uses future point (x₀ + h) to approximate derivative. First-order accuracy O(h)."
        case "Backward":
            methodDescriptionLabel.text = "Uses past point (x₀ - h) to approximate derivative. First-order accuracy O(h)."
        case "Central":
            methodDescriptionLabel.text = "Uses both future and past points for better accuracy. Second-order accuracy O(h²)."
        default:
            methodDescriptionLabel.text = ""
        }
    }

    private func updateAnalysisGraphs() {
        let viewModel = NumericalDiffViewModel(f: selectedFunction, method: method, h: h, x: x)
        
        // Error analysis graph
        let errorData = viewModel.errorAnalysis()
        let errorPoints = errorData.map { CGPoint(x: log10($0.h), y: log10($0.error)) }
        
        errorGraphView.configure(
            function: { x in x }, // Linear trend line
            xRange: -10...0,
            points: errorPoints,
            showGrid: true,
            gridStep: 1
        )
        
        // Convergence analysis graph
        let convergenceData = viewModel.convergenceAnalysis()
        let convergencePoints = convergenceData.map { CGPoint(x: Double($0.iteration), y: log10($0.error)) }
        
        convergenceGraphView.configure(
            function: { x in -2 * x - 1 }, // Expected convergence rate
            xRange: 0...9,
            points: convergencePoints,
            showGrid: true,
            gridStep: 1
        )
    }

    private func updateGraph() {
        let viewModel = NumericalDiffViewModel(f: selectedFunction, method: method, h: h, x: x)
        let approx = viewModel.derivativeApprox()
        let exact = viewModel.exactDerivative(x)
        let error = abs(approx - exact)
        let tangent = viewModel.tangentLine()
        
        // Configure graph with both function and tangent line
        graphView.xAxisLabel = "x"
        graphView.yAxisLabel = "f(x)"
        graphView.showLegend = false
        graphView.configure(
            function: selectedFunction,
            xRange: (x-2)...(x+2),
            points: [CGPoint(x: x, y: selectedFunction(x))],
            showGrid: true,
            gridStep: 0.5
        )
        graphView.secondaryFunction = tangent
        graphView.showOptimizationPath = true
        
        // Show method points
        var methodPoints: [CGPoint] = []
        switch method {
        case "Forward":
            methodPoints = [
                CGPoint(x: x, y: selectedFunction(x)),
                CGPoint(x: x + h, y: selectedFunction(x + h))
            ]
        case "Backward":
            methodPoints = [
                CGPoint(x: x - h, y: selectedFunction(x - h)),
                CGPoint(x: x, y: selectedFunction(x))
            ]
        case "Central":
            methodPoints = [
                CGPoint(x: x - h, y: selectedFunction(x - h)),
                CGPoint(x: x, y: selectedFunction(x)),
                CGPoint(x: x + h, y: selectedFunction(x + h))
            ]
        default:
            break
        }
        graphView.drawPoints = methodPoints
        
        // Update results
        let diffText = String(format: """
            Numerical Derivative: %.5f
            Exact Derivative: %.5f
            """, approx, exact)
        diffLabel.text = diffText
        
        // Show error and recommendation
        let errorText = String(format: "Absolute Error: %.5f", error)
        
        if error > 0.01 {
            errorLabel.text = errorText + "\nTry using a smaller step size (h) for better accuracy."
            errorLabel.textColor = .systemOrange
        } else {
            errorLabel.text = errorText
            errorLabel.textColor = .secondaryLabel
        }
        
        updateAnalysisGraphs()
    }
} 