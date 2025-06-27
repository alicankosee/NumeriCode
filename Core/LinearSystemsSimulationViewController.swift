import UIKit

struct LinearSystemViewModel {
    let size: Int
    let method: String // "Gauss", "Gauss-Jordan", "LU", "Jacobi", "Gauss-Seidel"
    let A: [[Double]]
    let b: [Double]
    
    // Step-by-step tracking
    var steps: [MatrixStep] = []
    var convergenceHistory: [[Double]] = []
    var errorHistory: [Double] = []
    var executionTime: TimeInterval = 0
    var errorMessage: String? = nil
    
    struct MatrixStep {
        let description: String
        let matrix: [[Double]]
        let vector: [Double]
        let highlightedRow: Int?
        let highlightedCol: Int?
    }

    // Gauss elimination with step tracking
    mutating func gaussSolution() -> [Double] {
        var A = self.A
        var b = self.b
        let n = size
        steps = []
        
        // Add initial state
        steps.append(MatrixStep(
            description: "Initial augmented matrix",
            matrix: A,
            vector: b,
            highlightedRow: nil,
            highlightedCol: nil
        ))
        
        // Forward elimination
        for i in 0..<n {
            // Find pivot
            var maxRow = i
            for k in (i+1)..<n {
                if abs(A[k][i]) > abs(A[maxRow][i]) {
                    maxRow = k
                }
            }
            
            // Swap rows if necessary
            if maxRow != i {
                A.swapAt(i, maxRow)
                b.swapAt(i, maxRow)
                steps.append(MatrixStep(
                    description: "Swapped rows \(i+1) and \(maxRow+1) for better pivot",
                    matrix: A,
                    vector: b,
                    highlightedRow: i,
                    highlightedCol: i
                ))
            }
            
            // Eliminate column i
            for j in (i+1)..<n {
                let factor = A[j][i] / A[i][i]
                for k in i..<n {
                    A[j][k] -= factor * A[i][k]
                }
                b[j] -= factor * b[i]
                
                steps.append(MatrixStep(
                    description: "Row \(j+1) = Row \(j+1) - (\(String(format: "%.2f", factor))) × Row \(i+1)",
                    matrix: A,
                    vector: b,
                    highlightedRow: j,
                    highlightedCol: i
                ))
            }
        }
        
        // Back substitution
        var x = Array(repeating: 0.0, count: n)
        for i in (0..<n).reversed() {
            var sum = b[i]
            for j in (i+1)..<n {
                sum -= A[i][j] * x[j]
            }
            x[i] = sum / A[i][i]
            
            steps.append(MatrixStep(
                description: "x\(i+1) = (\(String(format: "%.2f", sum))) / (\(String(format: "%.2f", A[i][i]))) = \(String(format: "%.4f", x[i]))",
                matrix: A,
                vector: b,
                highlightedRow: i,
                highlightedCol: i
            ))
        }
        return x
    }

    // Gauss-Jordan elimination with step tracking
    mutating func gaussJordanSolution() -> [Double] {
        var A = self.A
        var b = self.b
        let n = size
        steps = []
        for i in 0..<n {
            // Find pivot
            var maxRow = i
            for k in (i+1)..<n {
                if abs(A[k][i]) > abs(A[maxRow][i]) {
                    maxRow = k
                }
            }
            if abs(A[maxRow][i]) < 1e-10 {
                errorMessage = "Matrix is singular or division by zero error! No solution exists."
                return Array(repeating: 0.0, count: n)
            }
            if maxRow != i {
                A.swapAt(i, maxRow)
                b.swapAt(i, maxRow)
                steps.append(MatrixStep(
                    description: "Swapped rows \(i+1) and \(maxRow+1) for better pivot",
                    matrix: A,
                    vector: b,
                    highlightedRow: i,
                    highlightedCol: i
                ))
            }
            // Normalize pivot row
            let pivot = A[i][i]
            for k in i..<n {
                A[i][k] /= pivot
            }
            b[i] /= pivot
            steps.append(MatrixStep(
                description: "Normalized row \(i+1) by dividing by pivot",
                matrix: A,
                vector: b,
                highlightedRow: i,
                highlightedCol: i
            ))
            // Eliminate all other rows
            for j in 0..<n {
                if j == i { continue }
                let factor = A[j][i]
                for k in i..<n {
                    A[j][k] -= factor * A[i][k]
                }
                b[j] -= factor * b[i]
                steps.append(MatrixStep(
                    description: "Row \(j+1) = Row \(j+1) - (\(String(format: "%.2f", factor))) × Row \(i+1)",
                    matrix: A,
                    vector: b,
                    highlightedRow: j,
                    highlightedCol: i
                ))
            }
        }
        return b
    }

    // LU decomposition with step tracking (Doolittle's method)
    mutating func luSolution() -> [Double] {
        let n = size
        var L = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        var U = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        for i in 0..<n { L[i][i] = 1.0 }
        // Decompose A = LU
        for i in 0..<n {
            for k in i..<n {
                var sum = 0.0
                for j in 0..<i { sum += L[i][j] * U[j][k] }
                U[i][k] = A[i][k] - sum
            }
            for k in (i+1)..<n {
                if abs(U[i][i]) < 1e-10 {
                    errorMessage = "Division by zero during LU decomposition! Matrix is singular."
                    return Array(repeating: 0.0, count: n)
                }
                var sum = 0.0
                for j in 0..<i { sum += L[k][j] * U[j][i] }
                L[k][i] = (A[k][i] - sum) / U[i][i]
            }
        }
        steps.append(MatrixStep(description: "LU decomposition completed.", matrix: U, vector: b, highlightedRow: nil, highlightedCol: nil))
        // Solve Ly = b
        var y = Array(repeating: 0.0, count: n)
        for i in 0..<n {
            var sum = b[i]
            for j in 0..<i { sum -= L[i][j] * y[j] }
            y[i] = sum / L[i][i]
        }
        // Solve Ux = y
        var x = Array(repeating: 0.0, count: n)
        for i in (0..<n).reversed() {
            var sum = y[i]
            for j in (i+1)..<n { sum -= U[i][j] * x[j] }
            if abs(U[i][i]) < 1e-10 {
                errorMessage = "Division by zero in LU solution! Matrix is singular."
                return Array(repeating: 0.0, count: n)
            }
            x[i] = sum / U[i][i]
        }
        steps.append(MatrixStep(description: "Solution completed.", matrix: U, vector: x, highlightedRow: nil, highlightedCol: nil))
        return x
    }

    // Check if matrix is diagonally dominant (sufficient condition for convergence)
    private func isDiagonallyDominant() -> Bool {
        for i in 0..<size {
            var diagonalElement = abs(A[i][i])
            var sumOfOffDiagonal = 0.0
            for j in 0..<size {
                if i != j {
                    sumOfOffDiagonal += abs(A[i][j])
                }
            }
            if diagonalElement <= sumOfOffDiagonal {
                return false
            }
        }
        return true
    }
    
    // Check if matrix is symmetric positive definite (another convergence condition)
    private func isSymmetricPositiveDefinite() -> Bool {
        // Check if matrix is symmetric
        for i in 0..<size {
            for j in 0..<size {
                if abs(A[i][j] - A[j][i]) > 1e-10 {
                    return false
                }
            }
        }
        // For simplicity, we'll just check if diagonal elements are positive
        for i in 0..<size {
            if A[i][i] <= 0 {
                return false
            }
        }
        return true
    }
    
    // Analyze convergence conditions and return explanation
    private func analyzeConvergence() -> String {
        if isDiagonallyDominant() {
            return "Matrix is diagonally dominant - convergence guaranteed."
        } else if isSymmetricPositiveDefinite() {
            return "Matrix is symmetric positive definite - convergence likely."
        } else {
            return "Matrix is not diagonally dominant or symmetric positive definite - convergence not guaranteed."
        }
    }

    // Jacobi iteration with convergence tracking
    mutating func jacobiSolution(maxIter: Int = 50, tolerance: Double = 1e-6) -> [Double] {
        let startTime = CFAbsoluteTimeGetCurrent()
        let n = size
        var x = Array(repeating: 0.0, count: n)
        var xPrev = Array(repeating: 0.0, count: n)
        convergenceHistory = []
        errorHistory = []
        steps = []
        
        // Add convergence analysis
        let convergenceAnalysis = analyzeConvergence()
        steps.append(MatrixStep(
            description: "Starting Jacobi iteration with initial guess x = [0, 0, 0]\nConvergence analysis: \(convergenceAnalysis)",
            matrix: A,
            vector: b,
            highlightedRow: nil,
            highlightedCol: nil
        ))
        
        var converged = false
        for iter in 0..<maxIter {
            xPrev = x
            var xNew = Array(repeating: 0.0, count: n)
            
            for i in 0..<n {
                var sum = b[i]
                for j in 0..<n {
                    if i != j {
                        sum -= A[i][j] * x[j]
                    }
                }
                if abs(A[i][i]) < 1e-10 {
                    errorMessage = "Division by zero in Jacobi method! Matrix is singular."
                    return Array(repeating: 0.0, count: n)
                }
                xNew[i] = sum / A[i][i]
            }
            x = xNew
            
            // Track convergence
            convergenceHistory.append(x)
            
            // Calculate error
            let error = sqrt(x.enumerated().map { pow($0.element - xPrev[$0.offset], 2) }.reduce(0, +))
            errorHistory.append(error)
            
            if iter < 5 { // Show first 5 steps
                steps.append(MatrixStep(
                    description: "Iteration \(iter+1): x = [\(x.map { String(format: "%.4f", $0) }.joined(separator: ", "))], Error = \(String(format: "%.6f", error))",
                    matrix: A,
                    vector: b,
                    highlightedRow: nil,
                    highlightedCol: nil
                ))
            }
            
            if error < tolerance {
                steps.append(MatrixStep(
                    description: "Converged after \(iter+1) iterations with error = \(String(format: "%.6f", error))",
                    matrix: A,
                    vector: b,
                    highlightedRow: nil,
                    highlightedCol: nil
                ))
                converged = true
                break
            }
        }
        
        executionTime = CFAbsoluteTimeGetCurrent() - startTime
        if !converged {
            let analysis = analyzeConvergence()
            if analysis.contains("not guaranteed") {
                errorMessage = "Jacobi method did not converge. Matrix is not diagonally dominant or symmetric positive definite. Try Gauss elimination instead."
            } else {
                errorMessage = "Jacobi method did not converge within \(maxIter) iterations. Try increasing iterations or using a different method."
            }
        }
        return x
    }
    
    // Gauss-Seidel iteration with convergence tracking
    mutating func gaussSeidelSolution(maxIter: Int = 50, tolerance: Double = 1e-6) -> [Double] {
        let startTime = CFAbsoluteTimeGetCurrent()
        let n = size
        var x = Array(repeating: 0.0, count: n)
        var xPrev = Array(repeating: 0.0, count: n)
        convergenceHistory = []
        errorHistory = []
        steps = []
        
        // Add convergence analysis
        let convergenceAnalysis = analyzeConvergence()
        steps.append(MatrixStep(
            description: "Starting Gauss-Seidel iteration with initial guess x = [0, 0, 0]\nConvergence analysis: \(convergenceAnalysis)",
            matrix: A,
            vector: b,
            highlightedRow: nil,
            highlightedCol: nil
        ))
        
        var converged = false
        for iter in 0..<maxIter {
            xPrev = x
            
            for i in 0..<n {
                var sum = b[i]
                for j in 0..<n {
                    if i != j {
                        sum -= A[i][j] * x[j]
                    }
                }
                if abs(A[i][i]) < 1e-10 {
                    errorMessage = "Division by zero in Gauss-Seidel method! Matrix is singular."
                    return Array(repeating: 0.0, count: n)
                }
                x[i] = sum / A[i][i]
            }
            
            // Track convergence
            convergenceHistory.append(x)
            
            // Calculate error
            let error = sqrt(x.enumerated().map { pow($0.element - xPrev[$0.offset], 2) }.reduce(0, +))
            errorHistory.append(error)
            
            if iter < 5 { // Show first 5 steps
                steps.append(MatrixStep(
                    description: "Iteration \(iter+1): x = [\(x.map { String(format: "%.4f", $0) }.joined(separator: ", "))], Error = \(String(format: "%.6f", error))",
                    matrix: A,
                    vector: b,
                    highlightedRow: nil,
                    highlightedCol: nil
                ))
            }
            
            if error < tolerance {
                steps.append(MatrixStep(
                    description: "Converged after \(iter+1) iterations with error = \(String(format: "%.6f", error))",
                    matrix: A,
                    vector: b,
                    highlightedRow: nil,
                    highlightedCol: nil
                ))
                converged = true
                break
            }
        }
        
        executionTime = CFAbsoluteTimeGetCurrent() - startTime
        if !converged {
            let analysis = analyzeConvergence()
            if analysis.contains("not guaranteed") {
                errorMessage = "Gauss-Seidel method did not converge. Matrix is not diagonally dominant or symmetric positive definite. Try Gauss elimination instead."
            } else {
                errorMessage = "Gauss-Seidel method did not converge within \(maxIter) iterations. Try increasing iterations or using a different method."
            }
        }
        return x
    }

    mutating func solution() -> [Double] {
        switch method {
        case "Gauss": return gaussSolution()
        case "Gauss-Jordan": return gaussJordanSolution()
        case "LU": return luSolution()
        case "Jacobi": return jacobiSolution()
        case "Gauss-Seidel": return gaussSeidelSolution()
        default: return gaussSolution()
        }
    }
}

class LinearSystemsSimulationViewController: UIViewController {
    // UI Components
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    // Educational components
    private let titleLabel = UILabel()
    private let explanationLabel = UILabel()
    private let methodSelector = UISegmentedControl(items: ["Gauss Elimination", "Gauss-Jordan", "LU", "Jacobi", "Gauss-Seidel"])
    private let sizeSelector = UISegmentedControl(items: ["2×2", "3×3", "4×4"])
    
    // Matrix display
    private let matrixContainer = UIView()
    private let matrixTitleLabel = UILabel()
    private let matrixStackView = UIStackView()
    
    // Step-by-step display
    private let stepContainer = UIView()
    private let stepTitleLabel = UILabel()
    private let stepDescriptionLabel = UILabel()
    private let stepMatrixView = UIView()
    private let nextStepButton = UIButton(type: .system)
    private let prevStepButton = UIButton(type: .system)
    private let stepLabel = UILabel()
    
    // Results
    private let resultContainer = UIView()
    private let resultTitleLabel = UILabel()
    private let solutionLabel = UILabel()
    private let runButton = UIButton(type: .system)
    private let checkButton = UIButton(type: .system)
    private let checkResultLabel = UILabel()
    
    // Data
    private var method: String = "Gauss"
    private var size: Int = 3
    private var A: [[Double]] = []
    private var b: [Double] = []
    private var currentViewModel: LinearSystemViewModel?
    private var currentStep: Int = 0
    
    // Example systems
    private let examples: [String: (A: [[Double]], b: [Double])] = [
        "2×2": (
            A: [[4.0, 1.0], [1.0, 3.0]],  // Diagonally dominant - good for iterative methods
            b: [5.0, 6.0]
        ),
        "3×3": (
            A: [[4.0, 1.0, 0.0], [1.0, 4.0, 1.0], [0.0, 1.0, 4.0]],  // Diagonally dominant - good for iterative methods
            b: [10.0, 14.0, 14.0]
        ),
        "4×4": (
            A: [[5.0, 1.0, 0.0, 0.0], [1.0, 5.0, 1.0, 0.0], [0.0, 1.0, 5.0, 1.0], [0.0, 0.0, 1.0, 5.0]],  // Diagonally dominant - good for iterative methods
            b: [1.0, 5.0, 15.0, 56.0]
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Linear Systems Solver"
        setupUI()
        loadExample()
        updateDisplay()
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

        // Title and explanation
        titleLabel.text = "Linear Systems Solver"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        contentStack.addArrangedSubview(titleLabel)
        
        explanationLabel.text = "Learn how to solve systems of linear equations using different numerical methods. Watch the step-by-step process!"
        explanationLabel.font = .systemFont(ofSize: 16)
        explanationLabel.textColor = .secondaryLabel
        explanationLabel.numberOfLines = 0
        explanationLabel.textAlignment = .center
        contentStack.addArrangedSubview(explanationLabel)

        // Method selector
        let methodLabel = UILabel()
        methodLabel.text = "Choose Method:"
        methodLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentStack.addArrangedSubview(methodLabel)
        
        methodSelector.selectedSegmentIndex = 0
        methodSelector.addTarget(self, action: #selector(methodChanged), for: .valueChanged)
        contentStack.addArrangedSubview(methodSelector)

        // Size selector
        let sizeLabel = UILabel()
        sizeLabel.text = "System Size:"
        sizeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentStack.addArrangedSubview(sizeLabel)
        
        sizeSelector.selectedSegmentIndex = 1 // 3×3 default
        sizeSelector.addTarget(self, action: #selector(sizeChanged), for: .valueChanged)
        contentStack.addArrangedSubview(sizeSelector)

        // Matrix display
        setupMatrixDisplay()
        contentStack.addArrangedSubview(matrixContainer)

        // Run button
        runButton.setTitle("Solve Step by Step", for: .normal)
        runButton.backgroundColor = .systemBlue
        runButton.setTitleColor(.white, for: .normal)
        runButton.layer.cornerRadius = 10
        runButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        runButton.addTarget(self, action: #selector(runSimulation), for: .touchUpInside)
        contentStack.addArrangedSubview(runButton)

        // Step-by-step display
        setupStepDisplay()
        contentStack.addArrangedSubview(stepContainer)

        // Results
        setupResultDisplay()
        contentStack.addArrangedSubview(resultContainer)
    }
    
    private func setupMatrixDisplay() {
        matrixContainer.backgroundColor = .systemGray6
        matrixContainer.layer.cornerRadius = 12
        matrixContainer.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        matrixTitleLabel.text = "System Matrix"
        matrixTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        matrixTitleLabel.textAlignment = .center
        matrixContainer.addSubview(matrixTitleLabel)
        matrixTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        matrixStackView.axis = .vertical
        matrixStackView.spacing = 8
        matrixStackView.alignment = .center
        matrixContainer.addSubview(matrixStackView)
        matrixStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            matrixTitleLabel.topAnchor.constraint(equalTo: matrixContainer.topAnchor, constant: 16),
            matrixTitleLabel.leadingAnchor.constraint(equalTo: matrixContainer.leadingAnchor, constant: 16),
            matrixTitleLabel.trailingAnchor.constraint(equalTo: matrixContainer.trailingAnchor, constant: -16),
            
            matrixStackView.topAnchor.constraint(equalTo: matrixTitleLabel.bottomAnchor, constant: 16),
            matrixStackView.leadingAnchor.constraint(equalTo: matrixContainer.leadingAnchor, constant: 16),
            matrixStackView.trailingAnchor.constraint(equalTo: matrixContainer.trailingAnchor, constant: -16),
            matrixStackView.bottomAnchor.constraint(equalTo: matrixContainer.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupStepDisplay() {
        stepContainer.backgroundColor = .systemGray6
        stepContainer.layer.cornerRadius = 12
        stepContainer.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stepContainer.isHidden = true
        
        stepTitleLabel.text = "Step-by-Step Solution"
        stepTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        stepTitleLabel.textAlignment = .center
        stepContainer.addSubview(stepTitleLabel)
        stepTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stepDescriptionLabel.font = .systemFont(ofSize: 14)
        stepDescriptionLabel.textColor = .secondaryLabel
        stepDescriptionLabel.numberOfLines = 0
        stepDescriptionLabel.textAlignment = .center
        stepContainer.addSubview(stepDescriptionLabel)
        stepDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stepMatrixView.backgroundColor = .systemBackground
        stepMatrixView.layer.cornerRadius = 8
        stepContainer.addSubview(stepMatrixView)
        stepMatrixView.translatesAutoresizingMaskIntoConstraints = false
        
        // Navigation buttons
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        
        prevStepButton.setTitle("Previous", for: .normal)
        prevStepButton.backgroundColor = .systemGray
        prevStepButton.setTitleColor(.white, for: .normal)
        prevStepButton.layer.cornerRadius = 8
        prevStepButton.addTarget(self, action: #selector(prevStep), for: .touchUpInside)
        buttonStack.addArrangedSubview(prevStepButton)
        
        stepLabel.text = "Step 1 of 1"
        stepLabel.font = .systemFont(ofSize: 14, weight: .medium)
        stepLabel.textAlignment = .center
        buttonStack.addArrangedSubview(stepLabel)
        
        nextStepButton.setTitle("Next", for: .normal)
        nextStepButton.backgroundColor = .systemBlue
        nextStepButton.setTitleColor(.white, for: .normal)
        nextStepButton.layer.cornerRadius = 8
        nextStepButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        buttonStack.addArrangedSubview(nextStepButton)
        
        stepContainer.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stepTitleLabel.topAnchor.constraint(equalTo: stepContainer.topAnchor, constant: 16),
            stepTitleLabel.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor, constant: 16),
            stepTitleLabel.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor, constant: -16),
            
            stepDescriptionLabel.topAnchor.constraint(equalTo: stepTitleLabel.bottomAnchor, constant: 12),
            stepDescriptionLabel.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor, constant: 16),
            stepDescriptionLabel.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor, constant: -16),
            
            stepMatrixView.topAnchor.constraint(equalTo: stepDescriptionLabel.bottomAnchor, constant: 12),
            stepMatrixView.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor, constant: 16),
            stepMatrixView.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor, constant: -16),
            stepMatrixView.heightAnchor.constraint(equalToConstant: 120),
            
            buttonStack.topAnchor.constraint(equalTo: stepMatrixView.bottomAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupResultDisplay() {
        resultContainer.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        resultContainer.layer.cornerRadius = 12
        resultContainer.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        resultTitleLabel.text = "Solution"
        resultTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        resultTitleLabel.textAlignment = .center
        resultContainer.addSubview(resultTitleLabel)
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        solutionLabel.font = .systemFont(ofSize: 16)
        solutionLabel.textColor = .systemGreen
        solutionLabel.numberOfLines = 0
        solutionLabel.textAlignment = .center
        resultContainer.addSubview(solutionLabel)
        solutionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Check button
        checkButton.setTitle("Verify Solution", for: .normal)
        checkButton.backgroundColor = .systemGray
        checkButton.setTitleColor(.white, for: .normal)
        checkButton.layer.cornerRadius = 8
        checkButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        checkButton.addTarget(self, action: #selector(checkSolution), for: .touchUpInside)
        resultContainer.addSubview(checkButton)
        checkButton.translatesAutoresizingMaskIntoConstraints = false

        // Result label
        checkResultLabel.font = .systemFont(ofSize: 15, weight: .medium)
        checkResultLabel.textAlignment = .center
        checkResultLabel.numberOfLines = 0
        resultContainer.addSubview(checkResultLabel)
        checkResultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resultTitleLabel.topAnchor.constraint(equalTo: resultContainer.topAnchor, constant: 16),
            resultTitleLabel.leadingAnchor.constraint(equalTo: resultContainer.leadingAnchor, constant: 16),
            resultTitleLabel.trailingAnchor.constraint(equalTo: resultContainer.trailingAnchor, constant: -16),
            
            solutionLabel.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 12),
            solutionLabel.leadingAnchor.constraint(equalTo: resultContainer.leadingAnchor, constant: 16),
            solutionLabel.trailingAnchor.constraint(equalTo: resultContainer.trailingAnchor, constant: -16),

            checkButton.topAnchor.constraint(equalTo: solutionLabel.bottomAnchor, constant: 12),
            checkButton.centerXAnchor.constraint(equalTo: resultContainer.centerXAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: 120),
            checkButton.heightAnchor.constraint(equalToConstant: 36),

            checkResultLabel.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 8),
            checkResultLabel.leadingAnchor.constraint(equalTo: resultContainer.leadingAnchor, constant: 16),
            checkResultLabel.trailingAnchor.constraint(equalTo: resultContainer.trailingAnchor, constant: -16),
            checkResultLabel.bottomAnchor.constraint(equalTo: resultContainer.bottomAnchor, constant: -16)
        ])
    }

    @objc private func methodChanged() {
        let methods = ["Gauss", "Gauss-Jordan", "LU", "Jacobi", "Gauss-Seidel"]
        method = methods[methodSelector.selectedSegmentIndex]
        stepContainer.isHidden = true
        resultContainer.isHidden = true
    }
    
    @objc private func sizeChanged() {
        let sizes = [2, 3, 4]
        size = sizes[sizeSelector.selectedSegmentIndex]
        loadExample()
        updateDisplay()
        stepContainer.isHidden = true
        resultContainer.isHidden = true
    }
    
    private func loadExample() {
        let sizeKey = "\(size)×\(size)"
        if let example = examples[sizeKey] {
            A = example.A
            b = example.b
        }
    }
    
    private func updateDisplay() {
        // Clear previous matrix display
        matrixStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create matrix display
        for (i, row) in A.enumerated() {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.alignment = .center
            
            // Matrix elements
            for (j, element) in row.enumerated() {
                let elementLabel = UILabel()
                elementLabel.text = String(format: "%.1f", element)
                elementLabel.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
                elementLabel.textAlignment = .center
                if abs(element) < 1e-8 {
                    elementLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
                } else {
                    elementLabel.backgroundColor = .systemBackground
                }
                elementLabel.layer.cornerRadius = 4
                elementLabel.layer.masksToBounds = true
                elementLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
                elementLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
                rowStack.addArrangedSubview(elementLabel)
            }
            
            // Separator
            let separatorLabel = UILabel()
            separatorLabel.text = "|"
            separatorLabel.font = .systemFont(ofSize: 18, weight: .bold)
            separatorLabel.textColor = .systemBlue
            rowStack.addArrangedSubview(separatorLabel)
            
            // Vector element
            let vectorLabel = UILabel()
            vectorLabel.text = String(format: "%.1f", b[i])
            vectorLabel.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
            vectorLabel.textAlignment = .center
            vectorLabel.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            vectorLabel.layer.cornerRadius = 4
            vectorLabel.layer.masksToBounds = true
            vectorLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
            vectorLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
            rowStack.addArrangedSubview(vectorLabel)
            
            matrixStackView.addArrangedSubview(rowStack)
        }
    }
    
    @objc private func runSimulation() {
        let methods = ["Gauss", "Gauss-Jordan", "LU", "Jacobi", "Gauss-Seidel"]
        method = methods[methodSelector.selectedSegmentIndex]
        var viewModel = LinearSystemViewModel(size: size, method: method, A: A, b: b)
        let solution = viewModel.solution()
        currentViewModel = viewModel
        currentStep = 0
        
        // Show step-by-step display
        stepContainer.isHidden = false
        resultContainer.isHidden = false
        
        // Update solution
        let solutionText = solution.enumerated().map { "x\($0.offset + 1) = \(String(format: "%.4f", $0.element))" }.joined(separator: "\n")
        solutionLabel.text = solutionText
        checkResultLabel.text = ""
        // Show error message
        if let errorMsg = viewModel.errorMessage {
            checkResultLabel.text = errorMsg
            checkResultLabel.textColor = .systemRed
        }
        // Show first step
        updateStepDisplay()
    }
    
    @objc private func nextStep() {
        guard let viewModel = currentViewModel else { return }
        if currentStep < viewModel.steps.count - 1 {
            currentStep += 1
            updateStepDisplay()
        }
    }
    
    @objc private func prevStep() {
        if currentStep > 0 {
            currentStep -= 1
            updateStepDisplay()
        }
    }
    
    private func updateStepDisplay() {
        guard let viewModel = currentViewModel, currentStep < viewModel.steps.count else { return }
        
        let step = viewModel.steps[currentStep]
        stepDescriptionLabel.text = step.description
        stepLabel.text = "Step \(currentStep + 1) of \(viewModel.steps.count)"
        
        // Update matrix display for this step
        updateStepMatrixDisplay(step: step)
        
        // Update button states
        prevStepButton.isEnabled = currentStep > 0
        nextStepButton.isEnabled = currentStep < viewModel.steps.count - 1
    }
    
    private func updateStepMatrixDisplay(step: LinearSystemViewModel.MatrixStep) {
        // Clear previous display
        stepMatrixView.subviews.forEach { $0.removeFromSuperview() }
        
        let matrixStack = UIStackView()
        matrixStack.axis = .vertical
        matrixStack.spacing = 4
        matrixStack.alignment = .center
        
        for (i, row) in step.matrix.enumerated() {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.alignment = .center
            
            for (j, element) in row.enumerated() {
                let elementLabel = UILabel()
                elementLabel.text = String(format: "%.2f", element)
                elementLabel.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
                elementLabel.textAlignment = .center
                if abs(element) < 1e-8 {
                    elementLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
                } else {
                    elementLabel.backgroundColor = .systemBackground
                }
                elementLabel.layer.cornerRadius = 3
                elementLabel.layer.masksToBounds = true
                elementLabel.widthAnchor.constraint(equalToConstant: 35).isActive = true
                elementLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
                
                // Highlight if this is the current focus
                if i == step.highlightedRow && j == step.highlightedCol {
                    elementLabel.backgroundColor = .systemYellow.withAlphaComponent(0.3)
                    elementLabel.layer.borderWidth = 2
                    elementLabel.layer.borderColor = UIColor.systemOrange.cgColor
                }
                
                rowStack.addArrangedSubview(elementLabel)
            }
            
            // Separator
            let separatorLabel = UILabel()
            separatorLabel.text = "|"
            separatorLabel.font = .systemFont(ofSize: 14, weight: .bold)
            separatorLabel.textColor = .systemBlue
            rowStack.addArrangedSubview(separatorLabel)
            
            // Vector element
            let vectorLabel = UILabel()
            vectorLabel.text = String(format: "%.2f", step.vector[i])
            vectorLabel.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
            vectorLabel.textAlignment = .center
            vectorLabel.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            vectorLabel.layer.cornerRadius = 3
            vectorLabel.layer.masksToBounds = true
            vectorLabel.widthAnchor.constraint(equalToConstant: 35).isActive = true
            vectorLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
            rowStack.addArrangedSubview(vectorLabel)
            
            matrixStack.addArrangedSubview(rowStack)
        }
        
        stepMatrixView.addSubview(matrixStack)
        matrixStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            matrixStack.centerXAnchor.constraint(equalTo: stepMatrixView.centerXAnchor),
            matrixStack.centerYAnchor.constraint(equalTo: stepMatrixView.centerYAnchor)
        ])
    }

    @objc private func checkSolution() {
        guard let viewModel = currentViewModel else { return }
        // Create a mutable copy to call solution()
        var mutableViewModel = viewModel
        let solution = mutableViewModel.solution()
        let Ax = multiplyMatrixVector(A: viewModel.A, x: solution)
        let b = viewModel.b
        let tolerance = 1e-4
        var isCorrect = true
        for (ai, bi) in zip(Ax, b) {
            if abs(ai - bi) > tolerance {
                isCorrect = false
                break
            }
        }
        if isCorrect {
            checkResultLabel.text = "Solution is correct! Ax ≈ b is satisfied."
            checkResultLabel.textColor = .systemGreen
        } else {
            checkResultLabel.text = "Solution is incorrect or approximate result does not satisfy Ax ≈ b."
            checkResultLabel.textColor = .systemRed
        }
    }

    private func multiplyMatrixVector(A: [[Double]], x: [Double]) -> [Double] {
        var result = [Double](repeating: 0.0, count: A.count)
        for i in 0..<A.count {
            for j in 0..<x.count {
                result[i] += A[i][j] * x[j]
            }
        }
        return result
    }
} 