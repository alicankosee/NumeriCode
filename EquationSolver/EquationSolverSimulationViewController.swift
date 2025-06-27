import UIKit

class EquationSolverSimulationViewController: BaseViewController {
    // MARK: - Properties
    private let methodSegmentedControl = UISegmentedControl(items: ["Bisection", "Newton", "Secant"])
    private let functionSegmentedControl = UISegmentedControl(items: [
        "f(x) = x^3 - 4x + 1",
        "f(x) = exp(x) - x^2",
        "f(x) = sin(x) - x/2"
    ])
    private let toleranceTextField = UITextField()
    private let solveButton = UIButton(type: .system)
    private let resultLabel = UILabel()
    private let iterationsLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let graphView = GraphView()
    private let errorGraphView = GraphView()
    private let errorGraphTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Error per Iteration"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    private let errorGraphCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "This shows the convergence of the method by plotting |f(xₙ)| over iterations."
        label.font = UIFont.italicSystemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    private var lastRoot: Double? = nil
    private let iterationsTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        tv.backgroundColor = UIColor.secondarySystemBackground
        tv.layer.cornerRadius = 8
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        tv.textContainer.lineBreakMode = .byWordWrapping
        tv.textContainer.lineFragmentPadding = 0
        tv.heightAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        return tv
    }()
    private let summaryBox: UIView = {
        let box = UIView()
        box.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        box.layer.cornerRadius = 10
        box.isHidden = true
        return box
    }()
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let summaryIcon: UILabel = {
        let icon = UILabel()
        icon.font = .systemFont(ofSize: 22)
        icon.text = "✅"
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "No solution to display."
        label.font = UIFont.italicSystemFont(ofSize: 17)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = false
        return label
    }()
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Solving, please wait..."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    private let functions: [(String, (Double) -> Double)] = [
        ("f(x) = x^3 - 4x + 1", { x in pow(x, 3) - 4 * x + 1 }),
        ("f(x) = exp(x) - x^2", { x in exp(x) - x * x }),
        ("f(x) = sin(x) - x/2", { x in sin(x) - x / 2 })
    ]
    private let derivatives: [(String, (Double) -> Double)] = [
        ("f'(x) = 3x^2 - 4", { x in 3 * x * x - 4 }),
        ("f'(x) = exp(x) - 2x", { x in exp(x) - 2 * x }),
        ("f'(x) = cos(x) - 0.5", { x in cos(x) - 0.5 })
    ]
    private let latexLabels: [String] = [
        "f(x) = x^3 - 4x + 1",
        "f(x) = e^x - x^2",
        "f(x) = \\sin(x) - \\frac{x}{2}"
    ]
    private let mathLabel = MTMathUILabel()
    private let methodFormulaLatex: [String] = [
        "x_n = \\frac{a_n + b_n}{2}",
        "x_{n+1} = x_n - \\frac{f(x_n)}{f'(x_n)}",
        "x_{n+1} = x_n - f(x_n) \\cdot \\frac{x_n - x_{n-1}}{f(x_n) - f(x_{n-1})}"
    ]
    private let methodFormulaLabel: MTMathUILabel = {
        let label = MTMathUILabel()
        label.fontSize = 20
        label.textAlignment = MTTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var iterationPoints: [CGPoint] = []
    private var guideLines: [[CGPoint]] = []
    private var errorValues: [Double] = []
    private var stepNumbers: [Int] = []
    private var errorGraphLogScale: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Equation Solver"
        setupUI()
        configureActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.distribution = .fill
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
        
        // Configure UI elements
        methodSegmentedControl.selectedSegmentIndex = 0
        
        let functionTitleLabel = UILabel()
        functionTitleLabel.text = "Select a function:"
        functionTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        functionTitleLabel.textAlignment = .left
        functionSegmentedControl.selectedSegmentIndex = 0
        
        // Input fields with better placeholders and default values
        toleranceTextField.placeholder = "Tolerance (e.g. 0.001)"
        toleranceTextField.borderStyle = .roundedRect
        toleranceTextField.keyboardType = .decimalPad
        toleranceTextField.text = "0.0001"
        
        // Add help button
        let helpButton = UIButton(type: .system)
        helpButton.setTitle("Help", for: .normal)
        helpButton.addTarget(self, action: #selector(showHelp), for: .touchUpInside)
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = "Solve"
        buttonConfig.baseBackgroundColor = .systemBlue
        solveButton.configuration = buttonConfig
        
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
        
        iterationsLabel.numberOfLines = 0
        iterationsLabel.textAlignment = .center
        
        mathLabel.latex = latexLabels[0]
        mathLabel.fontSize = 22
        mathLabel.textAlignment = MTTextAlignment.center
        mathLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(mathLabel)
        
        // GraphView ekle
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        graphView.backgroundColor = .secondarySystemBackground
        contentStack.addArrangedSubview(graphView)
        updateGraph()
        // Error graph ekle
        errorGraphTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(errorGraphTitleLabel)
        errorGraphView.translatesAutoresizingMaskIntoConstraints = false
        errorGraphView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        errorGraphView.backgroundColor = .tertiarySystemBackground
        contentStack.addArrangedSubview(errorGraphView)
        contentStack.addArrangedSubview(errorGraphCaptionLabel)
        updateErrorGraph()
        
        // Summary box ekle
        summaryBox.translatesAutoresizingMaskIntoConstraints = false
        summaryBox.addSubview(summaryIcon)
        summaryBox.addSubview(summaryLabel)
        contentStack.addArrangedSubview(summaryBox)
        NSLayoutConstraint.activate([
            summaryIcon.leadingAnchor.constraint(equalTo: summaryBox.leadingAnchor, constant: 12),
            summaryIcon.centerYAnchor.constraint(equalTo: summaryBox.centerYAnchor),
            summaryLabel.leadingAnchor.constraint(equalTo: summaryIcon.trailingAnchor, constant: 8),
            summaryLabel.trailingAnchor.constraint(equalTo: summaryBox.trailingAnchor, constant: -12),
            summaryLabel.topAnchor.constraint(equalTo: summaryBox.topAnchor, constant: 10),
            summaryLabel.bottomAnchor.constraint(equalTo: summaryBox.bottomAnchor, constant: -10)
        ])
        
        // Add elements to stack view
        [
            methodSegmentedControl,
            functionTitleLabel,
            functionSegmentedControl,
            toleranceTextField,
            helpButton,
            solveButton,
            loadingIndicator,
            progressLabel,
            resultLabel,
            iterationsLabel,
            iterationsTextView,
            methodFormulaLabel,
            placeholderLabel
        ].forEach { contentStack.addArrangedSubview($0) }
        
        // Setup loading indicator constraints - only one constraint to avoid conflict
        loadingIndicator.centerXAnchor.constraint(equalTo: solveButton.centerXAnchor).isActive = true
        
        functionSegmentedControl.addTarget(self, action: #selector(functionChanged), for: .valueChanged)
        methodSegmentedControl.addTarget(self, action: #selector(methodChanged), for: .valueChanged)
        
        updateMethodFormula()
    }
    
    private func configureActions() {
        solveButton.addTarget(self, action: #selector(solveTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func solveTapped() {
        // Start loading state
        startLoadingState()
        
        // Capture UI values on main thread before background processing
        let selectedFunctionIndex = functionSegmentedControl.selectedSegmentIndex
        let methodIdx = methodSegmentedControl.selectedSegmentIndex
        let toleranceText = toleranceTextField.text ?? ""
        
        // Perform calculation on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            guard selectedFunctionIndex >= 0 && selectedFunctionIndex < self.functions.count else {
                DispatchQueue.main.async {
                    self.stopLoadingState()
                    self.showAlert(title: "Error", message: "Please select a function")
                }
                return
            }
            
            let (functionName, function) = self.functions[selectedFunctionIndex]
            let method = ["Bisection", "Newton", "Secant"][methodIdx]
            
            guard let tolerance = Double(toleranceText),
                  tolerance > 0 else {
                DispatchQueue.main.async {
                    self.stopLoadingState()
                    self.showAlert(title: "Error", message: "Please enter valid tolerance (> 0)")
                }
                return
            }
            
            var result: (root: Double?, iterations: [Any], converged: Bool, errorMessage: String?) = (nil, [], false, nil)
            var found = false
            let maxTries = 50
            let step = 1.0
            var foundRoots: [Double] = []
            
            switch method {
            case "Bisection":
                var a = -5.0
                var b = 5.0
                for _ in 0..<maxTries {
                    let fa = function(a)
                    let fb = function(b)
                    if fa * fb <= 0 {
                        let bisectionResult = self.bisectionMethod(function: function, a: a, b: b, tolerance: tolerance)
                        if bisectionResult.converged || !bisectionResult.iterations.isEmpty, let root = bisectionResult.root {
                            if !foundRoots.contains(where: { abs($0 - root) < tolerance }) {
                                foundRoots.append(root)
                            }
                        }
                    }
                    a -= step
                    b += step
                }
                if let firstRoot = foundRoots.first {
                    let bisectionResult = self.bisectionMethod(function: function, a: firstRoot-step, b: firstRoot+step, tolerance: tolerance)
                    result = (bisectionResult.root, bisectionResult.iterations, bisectionResult.converged, nil)
                    found = true
                } else {
                    result = (nil, [], false, "No root found in the searched intervals.")
                }
            case "Secant":
                var x0 = -5.0
                var x1 = 5.0
                for _ in 0..<maxTries {
                    if abs(function(x0) - function(x1)) > 1e-10 {
                        let secantResult = self.secantMethod(function: function, x0: x0, x1: x1, tolerance: tolerance)
                        if secantResult.converged || !secantResult.iterations.isEmpty, let root = secantResult.root {
                            if !foundRoots.contains(where: { abs($0 - root) < tolerance }) {
                                foundRoots.append(root)
                            }
                        }
                    }
                    x0 -= step
                    x1 += step
                }
                if let firstRoot = foundRoots.first {
                    let secantResult = self.secantMethod(function: function, x0: firstRoot-step, x1: firstRoot+step, tolerance: tolerance)
                    result = (secantResult.root, secantResult.iterations, secantResult.converged, nil)
                    found = true
                } else {
                    result = (nil, [], false, "No root found in the searched intervals.")
                }
            case "Newton":
                var x0 = -5.0
                for _ in 0..<maxTries {
                    let newtonResult = self.newtonMethod(function: function, derivative: self.derivatives[selectedFunctionIndex].1, x0: x0, tolerance: tolerance)
                    if newtonResult.converged || !newtonResult.iterations.isEmpty, let root = newtonResult.root {
                        if !foundRoots.contains(where: { abs($0 - root) < tolerance }) {
                            foundRoots.append(root)
                        }
                    }
                    x0 += step
                }
                if let firstRoot = foundRoots.first {
                    let newtonResult = self.newtonMethod(function: function, derivative: self.derivatives[selectedFunctionIndex].1, x0: firstRoot-step, tolerance: tolerance)
                    result = (newtonResult.root, newtonResult.iterations, newtonResult.converged, nil)
                    found = true
                } else {
                    result = (nil, [], false, "No root found in the searched intervals.")
                }
            default:
                DispatchQueue.main.async {
                    self.stopLoadingState()
                    self.showAlert(title: "Error", message: "Unknown method selected")
                }
                return
            }
            
            if !found {
                result = (nil, [], false, "No root found automatically. You can increase the tolerance or select a different function. The root may be outside the search interval.")
            }
            
            if let errorMessage = result.errorMessage {
                DispatchQueue.main.async {
                    self.stopLoadingState()
                    self.showAlert(title: "Method Failed", message: errorMessage)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.stopLoadingState()
                self.displayResults(method: method, functionName: functionName, result: result, function: function, allRoots: foundRoots)
            }
        }
    }
    
    private func startLoadingState() {
        // Disable solve button
        solveButton.isEnabled = false
        solveButton.alpha = 0.6
        
        // Show loading indicator
        loadingIndicator.startAnimating()
        progressLabel.isHidden = false
        
        // Clear previous results
        resultLabel.text = ""
        iterationsTextView.text = ""
        summaryBox.isHidden = true
        graphView.isHidden = true
        errorGraphView.isHidden = true
        errorGraphTitleLabel.isHidden = true
        placeholderLabel.isHidden = true
        
        // Update progress label based on method
        let methodIdx = methodSegmentedControl.selectedSegmentIndex
        let method = ["Bisection", "Newton", "Secant"][methodIdx]
        progressLabel.text = "Solving with \(method) method..."
    }
    
    private func stopLoadingState() {
        // Re-enable solve button
        solveButton.isEnabled = true
        solveButton.alpha = 1.0
        
        // Hide loading indicator
        loadingIndicator.stopAnimating()
        progressLabel.isHidden = true
    }
    
    private func displayResults(method: String, functionName: String, result: (root: Double?, iterations: [Any], converged: Bool, errorMessage: String?), function: (Double) -> Double, allRoots: [Double]? = nil) {
        guard let root = result.root else {
            resultLabel.text = "Method failed to converge"
            return
        }
        
        let convergenceStatus = result.converged ? "✅ Converged" : "⚠️ Max iterations reached"
        var rootsText = ""
        if let allRoots = allRoots, !allRoots.isEmpty {
            rootsText = "Found root(s): " + allRoots.map { "x ≈ \(String(format: "%.6f", $0))" }.joined(separator: ", ") + "\n"
        } else {
            rootsText = "Root: x ≈ \(String(format: "%.6f", root))\n"
        }
        resultLabel.text = "\(method) Method - \(convergenceStatus)\n\(rootsText)f(x) = \(String(format: "%.2e", function(root)))"
        
        // Display iterations
        var iterationText = "Step-by-step solution:\n\n"
        
        for (index, step) in result.iterations.enumerated() {
            if let bisectionStep = step as? BisectionStep {
                iterationText += "\(bisectionStep.explanation)\n"
                if index == result.iterations.count - 1 {
                    iterationText += "✅ Root found!\n"
                }
                iterationText += "\n"
            } else if let newtonStep = step as? NewtonStep {
                iterationText += "\(newtonStep.explanation)\n"
                if index == result.iterations.count - 1 {
                    iterationText += "✅ Root found!\n"
                }
                iterationText += "\n"
            } else if let secantStep = step as? SecantStep {
                iterationText += "\(secantStep.explanation)\n"
                if index == result.iterations.count - 1 {
                    iterationText += "✅ Root found!\n"
                }
                iterationText += "\n"
            }
        }
        
        iterationsTextView.text = iterationText
        
        // Update graphs
        updateGraphsWithResults(result: result, function: function)
        
        // Update summary
        updateSummary(method: method, result: result, root: root, function: function)
        
        // Show results
        graphView.isHidden = false
        errorGraphView.isHidden = false
        errorGraphTitleLabel.isHidden = false
        placeholderLabel.isHidden = true
    }
    
    private func updateGraphsWithResults(result: (root: Double?, iterations: [Any], converged: Bool, errorMessage: String?), function: (Double) -> Double) {
        // Extract points for graph
        var iterationPoints: [CGPoint] = []
        var errorValues: [Double] = []
        var stepNumbers: [Int] = []
        
        for (index, step) in result.iterations.enumerated() {
            if let bisectionStep = step as? BisectionStep {
                iterationPoints.append(CGPoint(x: bisectionStep.mid, y: bisectionStep.fmid))
                errorValues.append(bisectionStep.error)
                stepNumbers.append(bisectionStep.iteration)
            } else if let newtonStep = step as? NewtonStep {
                iterationPoints.append(CGPoint(x: newtonStep.xNew, y: newtonStep.fx))
                errorValues.append(newtonStep.error)
                stepNumbers.append(newtonStep.iteration)
            } else if let secantStep = step as? SecantStep {
                iterationPoints.append(CGPoint(x: secantStep.x2, y: secantStep.f2))
                errorValues.append(secantStep.error)
                stepNumbers.append(secantStep.iteration)
            }
        }
        
        self.iterationPoints = iterationPoints
        self.errorValues = errorValues
        self.stepNumbers = stepNumbers
        
        updateGraph()
        updateErrorGraph()
    }
    
    private func updateSummary(method: String, result: (root: Double?, iterations: [Any], converged: Bool, errorMessage: String?), root: Double, function: (Double) -> Double) {
        let iterCount = result.iterations.count
        let finalError = errorValues.last ?? 0.0
        
        var summaryMsg = ""
        var icon = "✅"
        
        switch method {
        case "Bisection":
            summaryMsg = String(format: "Root found at x ≈ %.6f after %d iterations\nFinal error: %.2e\nBisection method: Slow but guaranteed convergence for continuous functions", root, iterCount, finalError)
            icon = "ℹ️"
        case "Newton":
            summaryMsg = String(format: "Root found at x ≈ %.6f after %d iterations\nFinal error: %.2e\nNewton-Raphson method: Fast quadratic convergence when close to root", root, iterCount, finalError)
            icon = "⚡"
        case "Secant":
            summaryMsg = String(format: "Root found at x ≈ %.6f after %d iterations\nFinal error: %.2e\nSecant method: Fast convergence without requiring derivatives", root, iterCount, finalError)
            icon = "📈"
        default:
            break
        }
        
        if !result.converged {
            summaryMsg += "\n⚠️ Method reached maximum iterations"
            icon = "⚠️"
        }
        
        summaryLabel.text = summaryMsg
        summaryIcon.text = icon
        summaryBox.isHidden = false
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func functionChanged() {
        let idx = functionSegmentedControl.selectedSegmentIndex
        if idx >= 0 && idx < latexLabels.count {
            mathLabel.latex = latexLabels[idx]
        }
        // Önceki simülasyon verilerini temizle ve tüm çıktıları gizle
        iterationsTextView.text = ""
        iterationPoints = []
        guideLines = []
        errorValues = []
        summaryBox.isHidden = true
        graphView.configure(function: functions[idx].1, xRange: -5...5, points: [])
        graphView.guideLines = []
        graphView.isHidden = true
        errorGraphView.drawPoints = []
        errorGraphView.isHidden = true
        errorGraphTitleLabel.isHidden = true
        placeholderLabel.isHidden = false
        errorGraphView.setNeedsDisplay()
        graphView.setNeedsDisplay()
    }
    
    @objc private func methodChanged() {
        updateMethodFormula()
    }
    
    @objc private func showHelp() {
        let methodIdx = methodSegmentedControl.selectedSegmentIndex
        let method = ["Bisection", "Newton", "Secant"][methodIdx]
        
        var helpMessage = ""
        switch method {
        case "Bisection":
            helpMessage = """
            Bisection Method Help:
            
            • Requires two values (a, b) where f(a) and f(b) have opposite signs
            • Guaranteed to converge for continuous functions
            • Slow but reliable convergence
            • Good starting values: [-5, 5] for most functions
            
            Example: Start=-5, End=5, Tolerance=0.0001
            """
        case "Newton":
            helpMessage = """
            Newton-Raphson Method Help:
            
            • Requires one starting value close to the root
            • Fast quadratic convergence when close to root
            • May fail if derivative is zero or initial guess is poor
            • Good starting values: -5.0, -4.5, or -4.0
            
            Example: Start=-5.0, Tolerance=0.0001
            """
        case "Secant":
            helpMessage = """
            Secant Method Help:
            
            • Requires two different starting values
            • Fast convergence without needing derivatives
            • May be less stable than Newton method
            • Good starting values: -5.0 and -4.0
            
            Example: Start=-5.0, End=-4.0, Tolerance=0.0001
            """
        default:
            helpMessage = "Please select a method first."
        }
        
        let alert = UIAlertController(title: "\(method) Method Help", message: helpMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateGraph() {
        let idx = functionSegmentedControl.selectedSegmentIndex
        let function = functions[idx].1
        graphView.configure(function: function, xRange: -5...5, points: iterationPoints)
        graphView.guideLines = guideLines
        graphView.setStepNumbers(stepNumbers)
        graphView.setNeedsDisplay()
    }
    
    private func updateErrorGraph() {
        // X: iterasyon (0,1,2...), Y: hata değeri
        guard !errorValues.isEmpty else {
            errorGraphView.drawPoints = []
            errorGraphView.setNeedsDisplay()
            return
        }
        let points = errorValues.enumerated().map { (i, err) in CGPoint(x: Double(i), y: err) }
        errorGraphView.function = nil
        errorGraphView.drawPoints = points
        errorGraphView.xRange = 0...(Double(errorValues.count-1))
        let maxY = (errorValues.max() ?? 1)
        errorGraphView.yRange = errorGraphLogScale ? log10(maxY+1e-10)...0 : 0...maxY
        errorGraphView.xAxisLabel = "Iteration"
        errorGraphView.yAxisLabel = "Error |f(xₙ)|"
        errorGraphView.curveDashed = true
        errorGraphView.curveColor = .systemRed
        errorGraphView.yLogScale = errorGraphLogScale
        errorGraphView.graphTitle = "Error per Iteration"
        errorGraphView.graphCaption = "This graph shows how the error |f(xₙ)| changes as the root-finding method progresses."
        if let last = errorValues.last, errorValues.count > 0 {
            errorGraphView.showFinalErrorLabel = true
            errorGraphView.finalErrorText = String(format: "Final Error ≈ %.4g at Step %d", last, errorValues.count)
        } else {
            errorGraphView.showFinalErrorLabel = false
            errorGraphView.finalErrorText = nil
        }
        errorGraphView.setNeedsDisplay()
    }
    
    private func updateMethodFormula() {
        let idx = methodSegmentedControl.selectedSegmentIndex
        if idx >= 0 && idx < methodFormulaLatex.count {
            methodFormulaLabel.latex = methodFormulaLatex[idx]
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Mathematical Algorithms
    private func bisectionMethod(function: (Double) -> Double, a: Double, b: Double, tolerance: Double, maxIterations: Int = 100) -> (root: Double?, iterations: [BisectionStep], converged: Bool) {
        var a = a, b = b
        var fa = function(a)
        var fb = function(b)
        if fa * fb > 0 {
            return (nil, [], false)
        }
        var iterations: [BisectionStep] = []
        var converged = false
        for i in 1...maxIterations {
            let mid = (a + b) / 2
            let fmid = function(mid)
            let error = abs(b - a) / 2 // Klasik bisection hata kriteri
            let step = BisectionStep(
                iteration: i,
                a: a, b: b,
                mid: mid,
                fa: fa, fb: fb, fmid: fmid,
                error: error,
                explanation: "Step \(i): Interval [\(String(format: "%.4f", a)), \(String(format: "%.4f", b))], Midpoint = \(String(format: "%.4f", mid)), f(mid) = \(String(format: "%.6f", fmid)), Error = \(String(format: "%.6e", error))"
            )
            iterations.append(step)
            if error < tolerance {
                converged = true
                return (mid, iterations, converged)
            }
            if fa * fmid < 0 {
                b = mid
                fb = fmid
            } else {
                a = mid
                fa = fmid
            }
        }
        return ((a + b) / 2, iterations, converged)
    }
    
    private func newtonMethod(function: (Double) -> Double, derivative: (Double) -> Double, x0: Double, tolerance: Double, maxIterations: Int = 100) -> (root: Double?, iterations: [NewtonStep], converged: Bool) {
        var x = x0
        var iterations: [NewtonStep] = []
        
        for i in 1...maxIterations {
            let fx = function(x)
            let fPrimeX = derivative(x)
            
            // Check for division by zero
            if abs(fPrimeX) < 1e-10 {
                return (nil, iterations, false)
            }
            
            let xNew = x - fx / fPrimeX
            let error = abs(xNew - x)
            
            let step = NewtonStep(
                iteration: i,
                x: x, xNew: xNew,
                fx: fx, fPrimeX: fPrimeX,
                error: error,
                explanation: "Step \(i): x = \(String(format: "%.6f", x)), f(x) = \(String(format: "%.6f", fx)), f'(x) = \(String(format: "%.6f", fPrimeX)), x_new = \(String(format: "%.6f", xNew))"
            )
            iterations.append(step)
            
            if error < tolerance {
                return (xNew, iterations, true)
            }
            
            x = xNew
        }
        
        return (x, iterations, false)
    }
    
    private func secantMethod(function: (Double) -> Double, x0: Double, x1: Double, tolerance: Double, maxIterations: Int = 100) -> (root: Double?, iterations: [SecantStep], converged: Bool) {
        var x0 = x0, x1 = x1
        var f0 = function(x0)
        var f1 = function(x1)
        var iterations: [SecantStep] = []
        
        for i in 1...maxIterations {
            // Check for division by zero
            if abs(f1 - f0) < 1e-10 {
                return (nil, iterations, false)
            }
            
            let x2 = x1 - f1 * (x1 - x0) / (f1 - f0)
            let f2 = function(x2)
            let error = abs(x2 - x1)
            
            let step = SecantStep(
                iteration: i,
                x0: x0, x1: x1, x2: x2,
                f0: f0, f1: f1, f2: f2,
                error: error,
                explanation: "Step \(i): x₀ = \(String(format: "%.6f", x0)), x₁ = \(String(format: "%.6f", x1)), x₂ = \(String(format: "%.6f", x2)), f(x₂) = \(String(format: "%.6f", f2))"
            )
            iterations.append(step)
            
            if error < tolerance {
                return (x2, iterations, true)
            }
            
            x0 = x1
            x1 = x2
            f0 = f1
            f1 = f2
        }
        
        return (x1, iterations, false)
    }
    
    // MARK: - Data Structures
    struct BisectionStep {
        let iteration: Int
        let a, b, mid: Double
        let fa, fb, fmid: Double
        let error: Double
        let explanation: String
    }
    
    struct NewtonStep {
        let iteration: Int
        let x, xNew: Double
        let fx, fPrimeX: Double
        let error: Double
        let explanation: String
    }
    
    struct SecantStep {
        let iteration: Int
        let x0, x1, x2: Double
        let f0, f1, f2: Double
        let error: Double
        let explanation: String
    }
} 
