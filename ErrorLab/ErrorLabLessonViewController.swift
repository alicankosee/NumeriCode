import UIKit

struct ErrorAnalysisViewModel {
    let errorType: String // "Round-off", "Truncation"
    let initialError: Double
    let iterations: Int

    func errorPropagation() -> [Double] {
        var errors: [Double] = [initialError]
        for i in 1..<iterations {
            let prev = errors.last ?? 0
            let next: Double
            if errorType == "Round-off" {
                next = prev * 0.9 // örnek: %10 azalma
            } else {
                next = prev + 0.01 // örnek: sabit artış
            }
            errors.append(next)
        }
        return errors
    }
}

class ErrorLabLessonViewController: BaseViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let graphView = GraphView()
    private let typeSelector = UISegmentedControl(items: ["Round-off", "Truncation"])
    private let initialField = UITextField()
    private let iterStepper = UIStepper()
    private let iterLabel = UILabel()
    private var errorType: String = "Round-off"
    private var initialError: Double = 0.05
    private var iterations: Int = 10
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContent()
        updateGraph()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Error Types & Floating Point"
        
        // Setup scroll view
        contentView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup stack view
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        
        // Setup graph view
        scrollView.addSubview(graphView)
        graphView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup type selector
        typeSelector.selectedSegmentIndex = 0
        typeSelector.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
        typeSelector.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(typeSelector)
        
        // Setup initial field
        initialField.placeholder = "Başlangıç Hatası"
        initialField.borderStyle = .roundedRect
        initialField.keyboardType = .decimalPad
        initialField.text = String(initialError)
        initialField.translatesAutoresizingMaskIntoConstraints = false
        initialField.addTarget(self, action: #selector(paramChanged), for: .editingChanged)
        scrollView.addSubview(initialField)
        
        // Setup iter stepper
        iterStepper.minimumValue = 2
        iterStepper.maximumValue = 50
        iterStepper.value = Double(iterations)
        iterStepper.addTarget(self, action: #selector(paramChanged), for: .valueChanged)
        iterStepper.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(iterStepper)
        
        // Setup iter label
        iterLabel.text = "İterasyon: \(iterations)"
        iterLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(iterLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            graphView.topAnchor.constraint(equalTo: initialField.bottomAnchor, constant: 24),
            graphView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            graphView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            graphView.heightAnchor.constraint(equalToConstant: 220),
            
            typeSelector.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            typeSelector.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            typeSelector.widthAnchor.constraint(equalToConstant: 220),
            
            initialField.topAnchor.constraint(equalTo: typeSelector.bottomAnchor, constant: 16),
            initialField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 32),
            initialField.widthAnchor.constraint(equalToConstant: 100),
            
            iterLabel.topAnchor.constraint(equalTo: typeSelector.bottomAnchor, constant: 16),
            iterLabel.leadingAnchor.constraint(equalTo: initialField.trailingAnchor, constant: 16),
            iterLabel.widthAnchor.constraint(equalToConstant: 100),
            
            iterStepper.centerYAnchor.constraint(equalTo: iterLabel.centerYAnchor),
            iterStepper.leadingAnchor.constraint(equalTo: iterLabel.trailingAnchor, constant: 8),
            iterStepper.widthAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    private func setupContent() {
        // Add lesson sections
        addSection(title: "Types of Errors", content: """
            In numerical computations, we encounter several types of errors:
            
            1. Round-off Error
            • Occurs due to finite precision of floating-point numbers
            • Example: 1/3 ≈ 0.333333...
            
            2. Truncation Error
            • Results from approximating infinite processes with finite ones
            • Example: Taylor series truncation
            
            3. Propagation Error
            • Accumulation of errors through calculations
            • Can grow or diminish depending on the algorithm
            """)
        
        addSection(title: "Floating-Point Numbers", content: """
            IEEE 754 Standard defines how computers represent real numbers:
            
            • Sign bit (1 bit)
            • Exponent (11 bits)
            • Mantissa (52 bits)
            
            This leads to limitations:
            • Not all decimals can be represented exactly
            • Limited precision and range
            • Spacing between numbers increases with magnitude
            """)
        
        addSection(title: "Best Practices", content: """
            To minimize numerical errors:
            
            1. Use appropriate data types
            2. Avoid subtracting nearly equal numbers
            3. Sort calculations by magnitude
            4. Consider alternative algorithms
            5. Validate results with different methods
            """)
    }
    
    private func addSection(title: String, content: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        
        let sectionStack = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        sectionStack.axis = .vertical
        sectionStack.spacing = 10
        
        stackView.addArrangedSubview(sectionStack)
    }
    
    @objc private func typeChanged() {
        let types = ["Round-off", "Truncation"]
        errorType = types[typeSelector.selectedSegmentIndex]
        updateGraph()
    }
    
    @objc private func paramChanged() {
        initialError = Double(initialField.text ?? "") ?? initialError
        iterations = Int(iterStepper.value)
        iterLabel.text = "İterasyon: \(iterations)"
        updateGraph()
    }
    
    private func updateGraph() {
        let viewModel = ErrorAnalysisViewModel(errorType: errorType, initialError: initialError, iterations: iterations)
        let errors = viewModel.errorPropagation()
        let points = errors.enumerated().map { CGPoint(x: Double($0.offset), y: $0.element) }
        graphView.configure(function: { x in
            let idx = Int(round(x))
            return (idx >= 0 && idx < errors.count) ? errors[idx] : 0
        }, xRange: 0...Double(errors.count-1), points: points)
    }
} 