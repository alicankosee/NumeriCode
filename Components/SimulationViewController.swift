import UIKit

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class SimulationViewController: BaseViewController {
    private let module: ModuleType
    private let titleLabel = UILabel()
    private let controlsStack = UIStackView()
    private let outputScrollView = UIScrollView()
    private let outputStack = UIStackView()
    private let resultLabel = UILabel()
    private let formulaLabel = UILabel()
    private let calcLabel = UILabel()
    private let errorLabel = UILabel()
    private var config: SimulationConfig?
    private var parameterValues: [String: Any] = [:]
    private let graphView = GraphView()
    private var selectedDiffFunctionLabel: String = "x²"
    private let functionOptions = ["x²", "sin(x)", "eˣ", "ln(x)"]
    private let functionSegmented = UISegmentedControl(items: ["x²", "sin(x)", "eˣ", "ln(x)"])
    private let integrationFunctionOptions = ["x²", "sin(x)", "eˣ", "1 / (1 + x²)", "√(1 - x²)"]
    private let integrationFunctionSegmented = UISegmentedControl(items: ["x²", "sin(x)", "eˣ", "1 / (1 + x²)", "√(1 - x²)"])
    private var selectedIntegrationFunctionLabel: String = "x²"
    
    init(module: ModuleType) {
        self.module = module
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ODE Solver için özel case
        if module == .odeSolver {
            let odeViewController = ODESolverSimulationViewController()
            addChild(odeViewController)
            view.addSubview(odeViewController.view)
            odeViewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                odeViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                odeViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                odeViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                odeViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            odeViewController.didMove(toParent: self)
            return
        }
        
        // Linear Systems için özel case
        if module == .linearSystemSolver {
            let linearVC = LinearSystemsSimulationViewController()
            addChild(linearVC)
            view.addSubview(linearVC.view)
            linearVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                linearVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                linearVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                linearVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                linearVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            linearVC.didMove(toParent: self)
            return
        }
        
        // Performance Analysis için özel case
        if module == .performance {
            let performanceVC = PerformanceAnalysisSimulationViewController()
            addChild(performanceVC)
            view.addSubview(performanceVC.view)
            performanceVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                performanceVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                performanceVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                performanceVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                performanceVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            performanceVC.didMove(toParent: self)
            return
        }
        
        // Optimization için özel case
        if module == .optimization {
            let optimizationVC = OptimizationSimulationViewController()
            addChild(optimizationVC)
            view.addSubview(optimizationVC.view)
            optimizationVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                optimizationVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                optimizationVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                optimizationVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                optimizationVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            optimizationVC.didMove(toParent: self)
            return
        }
        
        // LU Decomposition için özel case
        if module == .luDecomposition {
            let luVC = LUDecompositionSimulationViewController()
            addChild(luVC)
            view.addSubview(luVC.view)
            luVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                luVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                luVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                luVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                luVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            luVC.didMove(toParent: self)
            return
        }
        
        // Numerical Integration için özel case
        if module == .numericalIntegration {
            let integrationVC = NumericalIntegrationSimulationViewController()
            addChild(integrationVC)
            view.addSubview(integrationVC.view)
            integrationVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                integrationVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                integrationVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                integrationVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                integrationVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            integrationVC.didMove(toParent: self)
            return
        }
        
        // Numerical Differentiation için özel case
        if module == .numericalDifferentiation {
            let differentiationVC = NumericalDifferentiationSimulationViewController()
            addChild(differentiationVC)
            view.addSubview(differentiationVC.view)
            differentiationVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                differentiationVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                differentiationVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                differentiationVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                differentiationVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            differentiationVC.didMove(toParent: self)
            return
        }
        
        // Equation Solver için özel case
        if module == .equationSolver {
            let equationVC = EquationSolverSimulationViewController()
            addChild(equationVC)
            view.addSubview(equationVC.view)
            equationVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                equationVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                equationVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                equationVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                equationVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            equationVC.didMove(toParent: self)
            return
        }
        
        // Error Lab için özel case
        if module == .errorLab {
            let errorLabVC = ErrorLabSimulationViewController()
            addChild(errorLabVC)
            view.addSubview(errorLabVC.view)
            errorLabVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                errorLabVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                errorLabVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                errorLabVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                errorLabVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            errorLabVC.didMove(toParent: self)
            return
        }
        
        // Interpolator için özel case
        if module == .interpolator {
            let interpolatorVC = InterpolatorSimulationViewController()
            addChild(interpolatorVC)
            view.addSubview(interpolatorVC.view)
            interpolatorVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                interpolatorVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                interpolatorVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                interpolatorVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                interpolatorVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            interpolatorVC.didMove(toParent: self)
            return
        }
        
        setupUI()
        loadSimulationConfig()
    }
    
    private func setupUI() {
        title = "Simulation"
        view.backgroundColor = .systemBackground
        
        // Title Label
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Controls Stack
        controlsStack.axis = .vertical
        controlsStack.spacing = 16
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsStack)
        
        // Function Segmented Control (only for Numerical Differentiation)
        functionSegmented.selectedSegmentIndex = 0
        functionSegmented.addTarget(self, action: #selector(functionChanged(_:)), for: .valueChanged)
        functionSegmented.translatesAutoresizingMaskIntoConstraints = false
        
        // GraphView (Numerical Differentiation için)
        graphView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(graphView)
        
        // Output StackView (for better layout)
        outputStack.axis = .vertical
        outputStack.spacing = 8
        outputStack.alignment = .fill
        outputStack.distribution = .fill
        outputStack.translatesAutoresizingMaskIntoConstraints = false
        outputStack.isLayoutMarginsRelativeArrangement = true
        outputStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        // Result label (bold, large)
        resultLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        resultLabel.textColor = .systemBlue
        resultLabel.numberOfLines = 0
        resultLabel.adjustsFontForContentSizeCategory = true
        // Formula label
        formulaLabel.font = UIFont.preferredFont(forTextStyle: .body)
        formulaLabel.textColor = .label
        formulaLabel.numberOfLines = 0
        formulaLabel.adjustsFontForContentSizeCategory = true
        // Calculation label
        calcLabel.font = UIFont.preferredFont(forTextStyle: .body)
        calcLabel.textColor = .secondaryLabel
        calcLabel.numberOfLines = 0
        calcLabel.adjustsFontForContentSizeCategory = true
        // Error label
        errorLabel.font = UIFont.preferredFont(forTextStyle: .body)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.adjustsFontForContentSizeCategory = true
        // Add labels to stack
        outputStack.addArrangedSubview(resultLabel)
        outputStack.addArrangedSubview(formulaLabel)
        outputStack.addArrangedSubview(calcLabel)
        outputStack.addArrangedSubview(errorLabel)
        outputScrollView.translatesAutoresizingMaskIntoConstraints = false
        outputScrollView.alwaysBounceVertical = true
        outputScrollView.showsVerticalScrollIndicator = true
        view.addSubview(outputScrollView)
        outputScrollView.addSubview(outputStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            controlsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            graphView.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 16),
            graphView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            graphView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            graphView.heightAnchor.constraint(equalToConstant: 220),
            
            outputScrollView.topAnchor.constraint(equalTo: graphView.bottomAnchor, constant: 16),
            outputScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            outputScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            outputScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            
            outputStack.topAnchor.constraint(equalTo: outputScrollView.topAnchor),
            outputStack.leadingAnchor.constraint(equalTo: outputScrollView.leadingAnchor),
            outputStack.trailingAnchor.constraint(equalTo: outputScrollView.trailingAnchor),
            outputStack.bottomAnchor.constraint(equalTo: outputScrollView.bottomAnchor),
            outputStack.widthAnchor.constraint(equalTo: outputScrollView.widthAnchor)
        ])
    }
    
    private func loadSimulationConfig() {
        config = SimulationConfigLoader.loadConfig(for: module)
        guard let config = config else {
            titleLabel.text = "Simulation"
            resultLabel.text = "Simulation config not found."
            formulaLabel.text = ""
            calcLabel.text = ""
            errorLabel.text = ""
            return
        }
        titleLabel.text = config.simulationTitle
        resultLabel.text = config.output
        setupParameterControls(config.parameters)
    }
    
    private func setupParameterControls(_ parameters: [SimulationParameter]) {
        controlsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // parameterValues.removeAll() kaldırıldı, böylece değerler korunur
        // Numerical Differentiation için fonksiyon seçici ekle
        if config?.module == "Numerical Differentiation" {
            let label = UILabel()
            label.text = "Fonksiyon Seçimi"
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.numberOfLines = 1
            controlsStack.addArrangedSubview(label)
            controlsStack.addArrangedSubview(functionSegmented)
        }
        // Numerical Integration için fonksiyon seçici ekle
        if config?.module == "Numerical Integration" {
            let label = UILabel()
            label.text = "Fonksiyon Seçimi"
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.numberOfLines = 1
            controlsStack.addArrangedSubview(label)
            integrationFunctionSegmented.selectedSegmentIndex = 0
            integrationFunctionSegmented.addTarget(self, action: #selector(integrationFunctionChanged(_:)), for: .valueChanged)
            integrationFunctionSegmented.translatesAutoresizingMaskIntoConstraints = false
            controlsStack.addArrangedSubview(integrationFunctionSegmented)
        }
        for param in parameters {
            let label = UILabel()
            label.text = param.name + (param.description.isEmpty ? "" : "\n" + param.description)
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.numberOfLines = 0
            controlsStack.addArrangedSubview(label)
            
            switch param.type {
            case "slider":
                let slider = UISlider()
                if param.name.contains("h") || param.name.lowercased().contains("step size") {
                    slider.minimumValue = 0.01
                    slider.maximumValue = 1.0
                    if let currentValue = parameterValues[param.name] as? Float {
                        slider.value = currentValue
                    } else if let currentValue = parameterValues[param.name] as? Double {
                        slider.value = Float(currentValue)
                    } else {
                        slider.value = Float(param.defaultValue.doubleValue ?? 0.1)
                    }
                } else {
                    slider.minimumValue = Float(param.min ?? 0)
                    slider.maximumValue = Float(param.max ?? 1)
                    if let currentValue = parameterValues[param.name] as? Float {
                        slider.value = currentValue
                    } else if let currentValue = parameterValues[param.name] as? Double {
                        slider.value = Float(currentValue)
                    } else {
                        slider.value = Float(param.defaultValue.doubleValue ?? 0)
                    }
                }
                slider.tag = controlsStack.arrangedSubviews.count
                slider.addTarget(self, action: #selector(parameterChanged(_:)), for: .valueChanged)
                controlsStack.addArrangedSubview(slider)
                if let slider = slider as? UISlider {
                    let floatValue = slider.value
                    let doubleValue = Double(floatValue)
                    parameterValues[param.name] = doubleValue
                }
            case "stepper":
                let stepper = UIStepper()
                stepper.minimumValue = param.min ?? 0
                stepper.maximumValue = param.max ?? 1
                stepper.value = param.defaultValue.doubleValue ?? 0
                stepper.tag = controlsStack.arrangedSubviews.count
                stepper.addTarget(self, action: #selector(parameterChanged(_:)), for: .valueChanged)
                controlsStack.addArrangedSubview(stepper)
                parameterValues[param.name] = stepper.value
            case "segmented":
                let segmented = UISegmentedControl(items: param.options ?? [])
                var defaultValueString = ""
                let defaultValue = param.defaultValue
                if let doubleValue = defaultValue.doubleValue, floor(doubleValue) == doubleValue {
                    defaultValueString = String(Int(doubleValue))
                } else if let stringValue = defaultValue.stringValue {
                    defaultValueString = stringValue
                } else {
                    defaultValueString = String(describing: defaultValue)
                }
                let defaultIndex = param.options?.firstIndex(where: { $0 == defaultValueString }) ?? 0
                segmented.selectedSegmentIndex = defaultIndex
                segmented.tag = controlsStack.arrangedSubviews.count
                segmented.addTarget(self, action: #selector(parameterChanged(_:)), for: .valueChanged)
                controlsStack.addArrangedSubview(segmented)
                parameterValues[param.name] = param.options?[defaultIndex] ?? ""
            case "textField":
                let textField = UITextField()
                textField.placeholder = param.name
                textField.text = param.defaultValue.stringValue
                textField.borderStyle = .roundedRect
                textField.tag = controlsStack.arrangedSubviews.count
                textField.addTarget(self, action: #selector(parameterChanged(_:)), for: .editingChanged)
                controlsStack.addArrangedSubview(textField)
                parameterValues[param.name] = textField.text ?? ""
            default:
                break
            }
        }
    }
    
    private func doubleValue(_ any: Any?, default def: Double) -> Double {
        if let d = any as? Double { return d }
        if let f = any as? Float { return Double(f) }
        if let s = any as? String, let d = Double(s) { return d }
        return def
    }
    
    @objc private func functionChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        selectedDiffFunctionLabel = functionOptions[safe: index] ?? "x²"
        parameterChanged(sender)
    }
    
    @objc private func integrationFunctionChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        selectedIntegrationFunctionLabel = integrationFunctionOptions[safe: index] ?? "x²"
        parameterChanged(sender)
    }
    
    @objc private func parameterChanged(_ sender: Any) {
        guard let config = config else { return }
        print("DEBUG: config.module = '\(config.module)' (parameterChanged)")
        print("DEBUG: parameterValues = \(parameterValues)")
        let parameters = config.parameters
        var controlOffset = 0
        if config.module == "Numerical Differentiation" {
            // Fonksiyon seçici ve label stack'e eklendiği için offset 2
            controlOffset = 2
        }
        for (i, param) in parameters.enumerated() {
            let controlIndex = controlOffset + i * 2 + 1 // label, control, label, control...
            guard let control = controlsStack.arrangedSubviews[safe: controlIndex] else { continue }
            switch param.type {
            case "slider":
                if let slider = control as? UISlider {
                    let value = Double(slider.value)
                    parameterValues[param.name] = value
                    if param.name.contains("h") || param.name.lowercased().contains("step size") {
                        print("DEBUG: Slider '\(param.name)' value = \(value)")
                    }
                }
            case "stepper":
                if let stepper = control as? UIStepper {
                    parameterValues[param.name] = stepper.value
                }
            case "segmented":
                if let segmented = control as? UISegmentedControl, let options = param.options {
                    let selected = segmented.selectedSegmentIndex
                    parameterValues[param.name] = options[safe: selected] ?? ""
                }
            case "textField":
                if let textField = control as? UITextField {
                    parameterValues[param.name] = textField.text ?? ""
                }
            default:
                break
            }
        }

        // Numerical Differentiation
        if config.module == "Numerical Differentiation" {
            graphView.isHidden = false
            let method = parameterValues["Method"] as? String ?? "Forward"
            let h = doubleValue(parameterValues["Step Size (h)"], default: 0.1)
            let x0 = doubleValue(parameterValues["Point (x₀)"], default: 2.0)
            
            let f: (Double) -> Double
            let analyticalDerivative: (Double) -> Double
            
            switch selectedDiffFunctionLabel {
            case "sin(x)":
                f = { sin($0) }
                analyticalDerivative = { cos($0) }
            case "x²":
                f = { $0 * $0 }
                analyticalDerivative = { 2 * $0 }
            case "eˣ":
                f = { exp($0) }
                analyticalDerivative = { exp($0) }
            default:
                f = { sin($0) }
                analyticalDerivative = { cos($0) }
            }
            
            let formula: String
            var calc = ""
            var approx: Double = 0
            let fx0 = f(x0)
            let fx0h = f(x0 + h)
            let fx0_h = f(x0 - h)
            switch method.lowercased() {
            case "forward":
                formula = "f'(x) ≈ [f(x + h) - f(x)] / h"
                calc = "[f(\(String(format: "%.3f", x0 + h))) - f(\(String(format: "%.3f", x0)))] / \(String(format: "%.3f", h)) = [\(String(format: "%.4f", fx0h)) - \(String(format: "%.4f", fx0))] / \(String(format: "%.3f", h))"
                approx = (fx0h - fx0) / h
            case "backward":
                formula = "f'(x) ≈ [f(x) - f(x - h)] / h"
                calc = "[f(\(String(format: "%.3f", x0))) - f(\(String(format: "%.3f", x0 - h)))] / \(String(format: "%.3f", h)) = [\(String(format: "%.4f", fx0)) - \(String(format: "%.4f", fx0_h))] / \(String(format: "%.3f", h))"
                approx = (fx0 - fx0_h) / h
            case "central":
                formula = "f'(x) ≈ [f(x + h) - f(x - h)] / (2h)"
                calc = "[f(\(String(format: "%.3f", x0 + h))) - f(\(String(format: "%.3f", x0 - h)))] / (2 × \(String(format: "%.3f", h))) = [\(String(format: "%.4f", fx0h)) - \(String(format: "%.4f", fx0_h))] / \(String(format: "%.3f", 2*h))"
                approx = (fx0h - fx0_h) / (2 * h)
            default:
                formula = "f'(x) ≈ [f(x + h) - f(x)] / h"
                calc = "[f(\(String(format: "%.3f", x0 + h))) - f(\(String(format: "%.3f", x0)))] / \(String(format: "%.3f", h)) = [\(String(format: "%.4f", fx0h)) - \(String(format: "%.4f", fx0))] / \(String(format: "%.3f", h))"
                approx = (fx0h - fx0) / h
            }
            let trueDeriv = analyticalDerivative(x0)
            let error = approx - trueDeriv
            let errorText = String(format: "True: %.4f, Approx: %.4f, Error: %+0.4f", trueDeriv, approx, error)
            resultLabel.text = "Seçilen fonksiyon: \(selectedDiffFunctionLabel)"
            formulaLabel.text = "Yöntem: \(method)\nFormül: \(formula)"
            calcLabel.text = "Hesaplama: \(calc)\nApproximate derivative at x = \(x0): \(String(format: "%.4f", approx))"
            errorLabel.text = errorText
            
            // Teğet doğrusu hesapla
            let tangent: (Double) -> Double = { x in
                approx * (x - x0) + fx0
            }
            
            // Grafik güncelle
            graphView.highlightedPoint = nil
            graphView.configure(function: { _ in 0 }, xRange: 0...4)
            graphView.configure(function: f, xRange: 0...4)
            graphView.configure(function: { x in tangent(x) }, xRange: 0...4, points: [CGPoint(x: x0, y: f(x0))])
            graphView.highlightedPoint = CGPoint(x: x0, y: f(x0))
        }
        // Equation Solver
        else if config.module == "Equation Solver" {
            let method = parameterValues["Method"] as? String ?? "Bisection"
            let tolerance = doubleValue(parameterValues["Tolerance"], default: 0.01)
            resultLabel.text = "Selected method: \(method)\nTolerance: \(tolerance)\n(Visual root-finding steps would be shown here.)"
        }
        // Interpolation
        else if config.module == "Interpolation" {
            let method = parameterValues["Method"] as? String ?? "Linear"
            let n = doubleValue(parameterValues["Number of Points"], default: 4)
            resultLabel.text = "Interpolation method: \(method)\nNumber of points: \(Int(n))\n(Graph of interpolated curve would be shown here.)"
        }
        // Numerical Integration
        else if config.module == "Numerical Integration" {
            graphView.isHidden = false
            let f: (Double) -> Double
            switch selectedIntegrationFunctionLabel {
            case "sin(x)":
                f = { sin($0) }
            case "eˣ":
                f = { exp($0) }
            case "1 / (1 + x²)":
                f = { 1.0 / (1.0 + $0 * $0) }
            case "√(1 - x²)":
                f = { $0 >= -1 && $0 <= 1 ? sqrt(1.0 - $0 * $0) : 0.0 }
            default:
                f = { $0 * $0 }
            }
            let a = doubleValue(parameterValues["a"], default: 0)
            let b = doubleValue(parameterValues["b"], default: .pi)
            let n = Int(doubleValue(parameterValues["Intervals"], default: 10))
            let viewModel = NumericalIntegrationViewModel(f: f, a: a, b: b, n: n)
            let area = viewModel.trapezoidalValue()
            let polygons = viewModel.trapezoidPoints()
            graphView.configure(function: f, xRange: a...b)
            graphView.fillPolygons(polygons)
            resultLabel.text = "Seçilen fonksiyon: \(selectedIntegrationFunctionLabel)\nApproximate area under the curve: \(String(format: "%.4f", area))"
        }
        // Linear Systems
        else if config.module == "Linear Systems" {
            graphView.isHidden = false
            let method = parameterValues["Method"] as? String ?? "Gaussian Elimination"
            let viewModel = LinearSystemSolverViewModel(size: 3)
            var log: [String] = []
            let methodLower = method.lowercased()
            if methodLower.contains("gauss") && !methodLower.contains("seidel") {
                log = viewModel.solveUsingGaussianElimination()
            } else if methodLower.contains("jacobi") {
                log = viewModel.solveUsingJacobi()
            } else if methodLower.contains("seidel") {
                log = viewModel.solveUsingGaussSeidel()
            }
            print("DEBUG: method = \(method)")
            print("DEBUG: log.count = \(log.count)")
            print("DEBUG: log = \(log.joined(separator: "\n"))")
            resultLabel.text = log.joined(separator: "\n")
        }
        // LU Decomposition
        else if config.module == "LU Decomposition" {
            let showSteps = parameterValues["Show Steps"] as? String ?? "Yes"
            let size = doubleValue(parameterValues["Matrix Size"], default: 3)
            
            // GraphView'ı gizle (LU Decomposition için grafik kullanılmıyor)
            graphView.isHidden = true
            
            // Grafik alanına matematiksel açıklama ekle
            if view.viewWithTag(9999) == nil {
                let mathExplanationView = createLUDecompositionMathView()
                mathExplanationView.tag = 9999
                view.addSubview(mathExplanationView)
                NSLayoutConstraint.activate([
                    mathExplanationView.topAnchor.constraint(equalTo: graphView.topAnchor),
                    mathExplanationView.bottomAnchor.constraint(equalTo: graphView.bottomAnchor),
                    mathExplanationView.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
                    mathExplanationView.trailingAnchor.constraint(equalTo: graphView.trailingAnchor)
                ])
            }
            // Rastgele matris oluştur
            let matrixSize = Int(size)
            var A: [[Double]] = []
            for i in 0..<matrixSize {
                var row: [Double] = []
                for j in 0..<matrixSize {
                    row.append(Double.random(in: 1...9))
                }
                A.append(row)
            }
            
            // LU Decomposition hesapla
            let viewModel = LUDecompositionViewModel(size: matrixSize, showSteps: showSteps == "Yes", A: A)
            let (L, U, steps, error) = viewModel.decompose()
            
            if let error = error {
                resultLabel.text = "Matrix A:\n\(matrixToString(A))\n\nError: \(error)"
                formulaLabel.text = ""
                calcLabel.text = ""
                errorLabel.text = ""
            } else {
                var result = "Matrix A:\n\(matrixToString(A))\n\nMatrix L:\n\(matrixToString(L))\n\nMatrix U:\n\(matrixToString(U))"
                
                if showSteps == "Yes" {
                    result += "\n\nStep-by-Step Calculation:\n" + steps.joined(separator: "\n\n")
                }
                
                resultLabel.text = result
                formulaLabel.text = "A = LU\nL = Lower triangular matrix with 1s on diagonal\nU = Upper triangular matrix"
                calcLabel.text = "Matrix size: \(matrixSize)x\(matrixSize)\nShow steps: \(showSteps)"
                errorLabel.text = "Decomposition completed successfully!"
            }
        }
        // Optimization
        else if config.module == "Optimization" {
            graphView.isHidden = false
            
            // Fixed function: f(x) = (x-3)² + 2
            let f: (Double) -> Double = { x in pow(x - 3, 2) + 2 }
            let derivative: (Double) -> Double = { x in 2 * (x - 3) }
            let secondDerivative: (Double) -> Double = { _ in 2.0 }
            
            let method = parameterValues["Method"] as? String ?? "Golden Section"
            let iterations = Int(doubleValue(parameterValues["Iterations"], default: 20))
            let initialX = 0.0
            
            var optimizationSteps: [Double] = []
            var finalX: Double = 0.0
            var finalValue: Double = 0.0
            var stepDetails: [String] = []
            
            switch method {
            case "Golden Section":
                // Golden Section Search
                var a = -5.0
                var b = 10.0
                let phi = (sqrt(5.0) - 1) / 2
                
                for i in 0..<iterations {
                    let c = b - phi * (b - a)
                    let d = a + phi * (b - a)
                    
                    optimizationSteps.append(c)
                    optimizationSteps.append(d)
                    stepDetails.append("Step \(i+1): c=\(String(format: "%.4f", c)), d=\(String(format: "%.4f", d))")
                    
                    if f(c) < f(d) {
                        b = d
                    } else {
                        a = c
                    }
                }
                finalX = (a + b) / 2
                finalValue = f(finalX)
                
            case "Newton":
                // Newton's Method
                var x = initialX
                optimizationSteps.append(x)
                stepDetails.append("Step 1: x₀ = \(String(format: "%.4f", x))")
                
                for i in 1..<iterations {
                    let fPrime = derivative(x)
                    let fDoublePrime = secondDerivative(x)
                    
                    if abs(fDoublePrime) < 1e-10 {
                        break
                    }
                    
                    x = x - fPrime / fDoublePrime
                    optimizationSteps.append(x)
                    stepDetails.append("Step \(i+1): x = \(String(format: "%.4f", x))")
                }
                finalX = x
                finalValue = f(x)
                
            case "Gradient Descent":
                // Gradient Descent
                var x = initialX
                let alpha = 0.1
                optimizationSteps.append(x)
                stepDetails.append("Step 1: x₀ = \(String(format: "%.4f", x))")
                
                for i in 1..<iterations {
                    let gradient = derivative(x)
                    x = x - alpha * gradient
                    optimizationSteps.append(x)
                    stepDetails.append("Step \(i+1): x = \(String(format: "%.4f", x))")
                }
                finalX = x
                finalValue = f(x)
                
            default:
                finalX = 3.0
                finalValue = 2.0
            }
            
            // Convert optimization steps to graph points
            let points = optimizationSteps.map { x in
                CGPoint(x: x, y: f(x))
            }
            
            // Configure graph
            graphView.configure(function: f, xRange: -5...10, points: points)
            graphView.showOptimizationPath = true
            
            // Set optimization method and steps for enhanced visualization
            graphView.optimizationMethod = method
            graphView.optimizationSteps = optimizationSteps
            
            // Set start and end points for enhanced visualization
            if let firstPoint = points.first, let lastPoint = points.last {
                graphView.startPoint = firstPoint
                graphView.endPoint = lastPoint
                graphView.highlightedPoint = lastPoint
            }
            
            // Update results
            let convergenceStatus = abs(finalX - 3.0) < 0.1 ? "✅ Converged" : "⚠️ Not converged"
            resultLabel.text = """
            🎯 Optimization Results:
            
            Method: \(method)
            Initial x₀: \(String(format: "%.4f", initialX))
            Iterations: \(iterations)
            
            📍 Final Result:
            x ≈ \(String(format: "%.6f", finalX))
            f(x) ≈ \(String(format: "%.6f", finalValue))
            
            \(convergenceStatus)
            """
            
            formulaLabel.text = "Function: f(x) = (x - 3)² + 2"
            calcLabel.text = "Global minimum at x = 3, f(3) = 2"
            errorLabel.text = stepDetails.joined(separator: "\n")
        }
        // ODE Solver
        else if config.module == "ODE Solver" {
            let method = parameterValues["Method"] as? String ?? "RK4"
            let h = doubleValue(parameterValues["Step Size (h)"], default: 0.1)
            resultLabel.text = "ODE Method: \(method)\nStep size: \(h)\n(Graph of solution over time would be shown here.)"
        }
        // Performance Analysis
        else if config.module == "Performance Analysis" {
            let algorithm = parameterValues["Algorithm"] as? String ?? "Gauss"
            let size = doubleValue(parameterValues["Problem Size"], default: 10)
            resultLabel.text = "Algorithm: \(algorithm)\nProblem size: \(Int(size))\n(Bar chart of computation time would be shown here.)"
        }
        // Error Analysis
        else if config.module == "Error Analysis" {
            let errorType = parameterValues["Error Type"] as? String ?? "Round-off"
            let initialError = doubleValue(parameterValues["Initial Error"], default: 0.05)
            let iterations = doubleValue(parameterValues["Iterations"], default: 10)
            resultLabel.text = "Error type: \(errorType)\nInitial error: \(initialError)\nIterations: \(Int(iterations))\n(Error propagation graph would be shown here.)"
        }
        else {
            resultLabel.text = config.output
        }
    }
    
    private func calculateNumericalDerivative(method: String, h: Double) -> Double {
        let f: (Double) -> Double = { x in x * x }
        let x = 2.0
        switch method {
        case "Forward":
            return (f(x + h) - f(x)) / h
        case "Backward":
            return (f(x) - f(x - h)) / h
        case "Central":
            return (f(x + h) - f(x - h)) / (2 * h)
        default:
            return 0
        }
    }
    
    private func matrixToString(_ matrix: [[Double]]) -> String {
        var result = ""
        for (i, row) in matrix.enumerated() {
            result += "  "
            for (j, val) in row.enumerated() {
                if i == j && matrix.count > 0 && matrix[0].count > 0 {
                    // Diagonal elemanları vurgula
                    result += String(format: "[%6.3f]", val)
                } else {
                    result += String(format: "%7.3f", val)
                }
                if j < row.count - 1 {
                    result += " "
                }
            }
            result += "\n"
        }
        return result
    }
    
    private func createLUDecompositionMathView() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.systemBackground
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Main formula label
        let formulaLabel = UILabel()
        formulaLabel.text = "A = LU"
        formulaLabel.font = .systemFont(ofSize: 24, weight: .bold)
        formulaLabel.textColor = .label
        formulaLabel.textAlignment = .center
        formulaLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(formulaLabel)
        
        // Matrix explanation
        let matrixExplanationLabel = UILabel()
        matrixExplanationLabel.text = "Where:"
        matrixExplanationLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        matrixExplanationLabel.textColor = .label
        matrixExplanationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(matrixExplanationLabel)
        
        // L matrix representation
        let lMatrixView = createMatrixView(
            title: "L (Lower Triangular):",
            matrix: [
                ["1", "0", "0"],
                ["l₂₁", "1", "0"],
                ["l₃₁", "l₃₂", "1"]
            ],
            highlightDiagonal: true
        )
        contentView.addSubview(lMatrixView)
        
        // U matrix representation
        let uMatrixView = createMatrixView(
            title: "U (Upper Triangular):",
            matrix: [
                ["u₁₁", "u₁₂", "u₁₃"],
                ["0", "u₂₂", "u₂₃"],
                ["0", "0", "u₃₃"]
            ],
            highlightDiagonal: false
        )
        contentView.addSubview(uMatrixView)
        
        // Explanation text
        let explanationLabel = UILabel()
        explanationLabel.text = "LU decomposition factors matrix A into lower and upper triangular matrices. Used for solving Ax = b efficiently."
        explanationLabel.font = .systemFont(ofSize: 16)
        explanationLabel.textColor = .secondaryLabel
        explanationLabel.numberOfLines = 0
        explanationLabel.textAlignment = .center
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(explanationLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Formula label
            formulaLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            formulaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            formulaLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Matrix explanation
            matrixExplanationLabel.topAnchor.constraint(equalTo: formulaLabel.bottomAnchor, constant: 20),
            matrixExplanationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            matrixExplanationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // L matrix
            lMatrixView.topAnchor.constraint(equalTo: matrixExplanationLabel.bottomAnchor, constant: 16),
            lMatrixView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            lMatrixView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // U matrix
            uMatrixView.topAnchor.constraint(equalTo: lMatrixView.bottomAnchor, constant: 20),
            uMatrixView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            uMatrixView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Explanation text
            explanationLabel.topAnchor.constraint(equalTo: uMatrixView.bottomAnchor, constant: 20),
            explanationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            explanationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            explanationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        return containerView
    }
    
    private func createMatrixView(title: String, matrix: [[String]], highlightDiagonal: Bool) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Matrix container
        let matrixContainer = UIView()
        matrixContainer.translatesAutoresizingMaskIntoConstraints = false
        matrixContainer.backgroundColor = UIColor.systemGray6
        matrixContainer.layer.cornerRadius = 8
        containerView.addSubview(matrixContainer)
        
        // Create matrix elements
        var matrixLabels: [[UILabel]] = []
        for (i, row) in matrix.enumerated() {
            var rowLabels: [UILabel] = []
            for (j, element) in row.enumerated() {
                let label = UILabel()
                label.text = element
                label.font = .systemFont(ofSize: 14, weight: .medium)
                label.textColor = highlightDiagonal && i == j ? .systemBlue : .label
                label.textAlignment = .center
                label.backgroundColor = highlightDiagonal && i == j ? UIColor.systemBlue.withAlphaComponent(0.1) : UIColor.clear
                label.layer.cornerRadius = 4
                label.layer.masksToBounds = true
                label.translatesAutoresizingMaskIntoConstraints = false
                matrixContainer.addSubview(label)
                rowLabels.append(label)
            }
            matrixLabels.append(rowLabels)
        }
        
        // Layout matrix elements
        let cellSize: CGFloat = 40
        let spacing: CGFloat = 8
        
        for (i, row) in matrixLabels.enumerated() {
            for (j, label) in row.enumerated() {
                NSLayoutConstraint.activate([
                    label.widthAnchor.constraint(equalToConstant: cellSize),
                    label.heightAnchor.constraint(equalToConstant: cellSize),
                    label.leadingAnchor.constraint(equalTo: matrixContainer.leadingAnchor, constant: spacing + CGFloat(j) * (cellSize + spacing)),
                    label.topAnchor.constraint(equalTo: matrixContainer.topAnchor, constant: spacing + CGFloat(i) * (cellSize + spacing))
                ])
            }
        }
        
        // Matrix container size
        let matrixWidth = CGFloat(matrix[0].count) * cellSize + CGFloat(matrix[0].count + 1) * spacing
        let matrixHeight = CGFloat(matrix.count) * cellSize + CGFloat(matrix.count + 1) * spacing
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            matrixContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            matrixContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            matrixContainer.widthAnchor.constraint(equalToConstant: matrixWidth),
            matrixContainer.heightAnchor.constraint(equalToConstant: matrixHeight),
            matrixContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
} 