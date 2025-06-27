import UIKit

struct LUDecompositionViewModel {
    let size: Int
    let showSteps: Bool
    let A: [[Double]]
    
    func decompose() -> (L: [[Double]], U: [[Double]], steps: [String], error: String?) {
        let n = size
        var L = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        var U = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        var steps: [String] = []
        
        for i in 0..<n {
            // Üst üçgen (U matrisi)
            for k in i..<n {
                var sum = 0.0
                for j in 0..<i {
                    sum += L[i][j] * U[j][k]
                }
                U[i][k] = A[i][k] - sum
                
                if showSteps {
                    if i == 0 {
                        steps.append("Step \(steps.count + 1): U[\(i)][\(k)] = A[\(i)][\(k)] = \(String(format: "%.3f", A[i][k]))")
                    } else {
                        steps.append("Step \(steps.count + 1): U[\(i)][\(k)] = A[\(i)][\(k)] - Σ(L[\(i)][j] * U[j][\(k)]) = \(String(format: "%.3f", A[i][k])) - \(String(format: "%.3f", sum)) = \(String(format: "%.3f", U[i][k]))")
                    }
                }
            }
            
            // Alt üçgen (L matrisi)
            for k in i..<n {
                if i == k {
                    L[i][i] = 1.0
                    if showSteps {
                        steps.append("Step \(steps.count + 1): L[\(i)][\(i)] = 1.0 (diagonal element)")
                    }
                } else {
                    var sum = 0.0
                    for j in 0..<i {
                        sum += L[k][j] * U[j][i]
                    }
                    
                    // Zero pivot kontrolü
                    if abs(U[i][i]) < 1e-10 {
                        return (L, U, steps, "LU decomposition failed: Zero pivot found at row \(i + 1).")
                    }
                    
                    L[k][i] = (A[k][i] - sum) / U[i][i]
                    
                    if showSteps {
                        steps.append("Step \(steps.count + 1): L[\(k)][\(i)] = (A[\(k)][\(i)] - Σ(L[\(k)][j] * U[j][\(i)])) / U[\(i)][\(i)] = (\(String(format: "%.3f", A[k][i])) - \(String(format: "%.3f", sum))) / \(String(format: "%.3f", U[i][i])) = \(String(format: "%.3f", L[k][i]))")
                    }
                }
            }
        }
        
        return (L, U, steps, nil)
    }
}

class LUDecompositionSimulationViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let sizeStepper = UIStepper()
    private let sizeLabel = UILabel()
    private let showStepsSwitch = UISwitch()
    private let showStepsLabel = UILabel()
    private let matrixATextView = UITextView()
    private let latexLabel = UILabel()
    private let matrixLTextView = UITextView()
    private let matrixUTextView = UITextView()
    private let stepsTextView = UITextView()
    private let matrixSizeInfoLabel = UILabel()
    private let matrixLGridScroll = UIScrollView()
    private let matrixUGridScroll = UIScrollView()
    private let matrixLGridStack = UIStackView()
    private let matrixUGridStack = UIStackView()
    private let stepsStack = UIStackView()
    private let resetOutputButton = UIButton(type: .system)
    private let lMatrixHeader = UILabel()
    private let uMatrixHeader = UILabel()
    private let lMatrixScroll = UIScrollView()
    private let uMatrixScroll = UIScrollView()
    private let lMatrixGrid = UIStackView()
    private let uMatrixGrid = UIStackView()
    private let stepsSectionView = UIView()
    private let infoLabel = UILabel()
    private let warningLabel = UILabel()
    private let scalingInfoLabel = UILabel()
    
    private var size: Int = 3
    private var showSteps: Bool = false
    private var A: [[Double]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "LU Decomposition"
        setupUI()
        generateMatrix()
        updateOutput()
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        // Kontroller
        let controlsStack = UIStackView()
        controlsStack.axis = .horizontal
        controlsStack.spacing = 16
        controlsStack.alignment = .center
        
        sizeLabel.text = "Matrix Size: \(size)"
        sizeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        controlsStack.addArrangedSubview(sizeLabel)
        
        sizeStepper.minimumValue = 2
        sizeStepper.maximumValue = 6
        sizeStepper.value = Double(size)
        sizeStepper.addTarget(self, action: #selector(sizeChanged), for: .valueChanged)
        controlsStack.addArrangedSubview(sizeStepper)
        
        showStepsLabel.text = "Show Steps:"
        showStepsLabel.font = .systemFont(ofSize: 16, weight: .medium)
        controlsStack.addArrangedSubview(showStepsLabel)
        
        showStepsSwitch.isOn = showSteps
        showStepsSwitch.addTarget(self, action: #selector(showStepsChanged), for: .valueChanged)
        controlsStack.addArrangedSubview(showStepsSwitch)
        
        contentStack.addArrangedSubview(controlsStack)
        
        // LaTeX formül
        latexLabel.text = "A = LU\nL = Lower triangular matrix with 1s on diagonal\nU = Upper triangular matrix"
        latexLabel.font = .systemFont(ofSize: 14, weight: .medium)
        latexLabel.textColor = .systemBlue
        latexLabel.numberOfLines = 0
        latexLabel.textAlignment = .center
        contentStack.addArrangedSubview(latexLabel)
        
        // Tips info card
        let tipsCard = createTipsCard()
        contentStack.addArrangedSubview(tipsCard)
        
        // Matrix A
        let matrixALabel = UILabel()
        matrixALabel.text = "Matrix A (Input):"
        matrixALabel.font = .boldSystemFont(ofSize: 16)
        contentStack.addArrangedSubview(matrixALabel)
        
        matrixATextView.isEditable = false
        matrixATextView.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        matrixATextView.backgroundColor = .systemGray6
        matrixATextView.layer.cornerRadius = 8
        matrixATextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        matrixATextView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        contentStack.addArrangedSubview(matrixATextView)
        
        // Matrix size info
        matrixSizeInfoLabel.font = .boldSystemFont(ofSize: 17)
        matrixSizeInfoLabel.textAlignment = .center
        matrixSizeInfoLabel.backgroundColor = UIColor.systemGray5
        matrixSizeInfoLabel.layer.cornerRadius = 8
        matrixSizeInfoLabel.layer.masksToBounds = true
        matrixSizeInfoLabel.textColor = .label
        matrixSizeInfoLabel.heightAnchor.constraint(equalToConstant: 36).isActive = true
        contentStack.addArrangedSubview(matrixSizeInfoLabel)
        
        // L Matrix Header
        lMatrixHeader.text = "Lower Triangular Matrix (L)"
        lMatrixHeader.font = .boldSystemFont(ofSize: 16)
        lMatrixHeader.textAlignment = .left
        contentStack.addArrangedSubview(lMatrixHeader)
        // L Matrix Grid
        lMatrixScroll.translatesAutoresizingMaskIntoConstraints = false
        lMatrixScroll.showsHorizontalScrollIndicator = true
        lMatrixScroll.backgroundColor = .clear
        lMatrixGrid.axis = .vertical
        lMatrixGrid.spacing = 0
        lMatrixGrid.alignment = .center
        lMatrixGrid.translatesAutoresizingMaskIntoConstraints = false
        lMatrixScroll.addSubview(lMatrixGrid)
        lMatrixGrid.topAnchor.constraint(equalTo: lMatrixScroll.topAnchor).isActive = true
        lMatrixGrid.leadingAnchor.constraint(equalTo: lMatrixScroll.leadingAnchor).isActive = true
        lMatrixGrid.trailingAnchor.constraint(equalTo: lMatrixScroll.trailingAnchor).isActive = true
        lMatrixGrid.bottomAnchor.constraint(equalTo: lMatrixScroll.bottomAnchor).isActive = true
        lMatrixScroll.heightAnchor.constraint(equalToConstant: 40 * CGFloat(size)).isActive = true
        contentStack.addArrangedSubview(lMatrixScroll)
        // Spacing
        let lToUSpacing = UIView(); lToUSpacing.heightAnchor.constraint(equalToConstant: 16).isActive = true
        contentStack.addArrangedSubview(lToUSpacing)
        // U Matrix Header
        uMatrixHeader.text = "Upper Triangular Matrix (U)"
        uMatrixHeader.font = .boldSystemFont(ofSize: 16)
        uMatrixHeader.textAlignment = .left
        contentStack.addArrangedSubview(uMatrixHeader)
        // U Matrix Grid
        uMatrixScroll.translatesAutoresizingMaskIntoConstraints = false
        uMatrixScroll.showsHorizontalScrollIndicator = true
        uMatrixScroll.backgroundColor = .clear
        uMatrixGrid.axis = .vertical
        uMatrixGrid.spacing = 0
        uMatrixGrid.alignment = .center
        uMatrixGrid.translatesAutoresizingMaskIntoConstraints = false
        uMatrixScroll.addSubview(uMatrixGrid)
        uMatrixGrid.topAnchor.constraint(equalTo: uMatrixScroll.topAnchor).isActive = true
        uMatrixGrid.leadingAnchor.constraint(equalTo: uMatrixScroll.leadingAnchor).isActive = true
        uMatrixGrid.trailingAnchor.constraint(equalTo: uMatrixScroll.trailingAnchor).isActive = true
        uMatrixGrid.bottomAnchor.constraint(equalTo: uMatrixScroll.bottomAnchor).isActive = true
        uMatrixScroll.heightAnchor.constraint(equalToConstant: 40 * CGFloat(size)).isActive = true
        contentStack.addArrangedSubview(uMatrixScroll)
        // Spacing
        let uToStepsSpacing = UIView(); uToStepsSpacing.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentStack.addArrangedSubview(uToStepsSpacing)
        // Steps Section
        stepsSectionView.backgroundColor = UIColor.systemGray6
        stepsSectionView.layer.cornerRadius = 12
        stepsSectionView.translatesAutoresizingMaskIntoConstraints = false
        stepsStack.axis = .vertical
        stepsStack.spacing = 12
        stepsStack.alignment = .fill
        stepsStack.translatesAutoresizingMaskIntoConstraints = false
        stepsSectionView.addSubview(stepsStack)
        stepsStack.topAnchor.constraint(equalTo: stepsSectionView.topAnchor, constant: 16).isActive = true
        stepsStack.leadingAnchor.constraint(equalTo: stepsSectionView.leadingAnchor, constant: 16).isActive = true
        stepsStack.trailingAnchor.constraint(equalTo: stepsSectionView.trailingAnchor, constant: -16).isActive = true
        stepsStack.bottomAnchor.constraint(equalTo: stepsSectionView.bottomAnchor, constant: -16).isActive = true
        contentStack.addArrangedSubview(stepsSectionView)
        // Spacing before reset
        let stepsToResetSpacing = UIView(); stepsToResetSpacing.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentStack.addArrangedSubview(stepsToResetSpacing)
        // Reset Output button
        var resetConfig = UIButton.Configuration.bordered()
        resetConfig.title = "Reset Output"
        resetConfig.baseForegroundColor = .systemRed
        resetOutputButton.configuration = resetConfig
        resetOutputButton.addTarget(self, action: #selector(resetOutputTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(resetOutputButton)
        
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.textColor = .secondaryLabel
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.isHidden = true
        contentStack.addArrangedSubview(infoLabel)
        warningLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        warningLabel.textColor = .systemOrange
        warningLabel.textAlignment = .center
        warningLabel.numberOfLines = 0
        warningLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.08)
        warningLabel.layer.cornerRadius = 8
        warningLabel.layer.masksToBounds = true
        warningLabel.isHidden = true
        contentStack.addArrangedSubview(warningLabel)
        
        scalingInfoLabel.font = .italicSystemFont(ofSize: 13)
        scalingInfoLabel.textColor = .secondaryLabel
        scalingInfoLabel.textAlignment = .center
        scalingInfoLabel.numberOfLines = 2
        scalingInfoLabel.text = "Matrices have been scaled to fit your screen. Values may appear smaller for larger matrix sizes."
        scalingInfoLabel.isHidden = true
        contentStack.addArrangedSubview(scalingInfoLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    @objc private func sizeChanged() {
        size = Int(sizeStepper.value)
        sizeLabel.text = "Matrix Size: \(size)"
        generateMatrix()
        clearOutput()
        updateOutput()
    }
    
    @objc private func showStepsChanged() {
        showSteps = showStepsSwitch.isOn
        clearOutput()
        updateOutput()
    }
    
    @objc private func resetOutputTapped() {
        clearOutput()
        matrixSizeInfoLabel.text = ""
    }
    
    private func clearOutput() {
        lMatrixGrid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        uMatrixGrid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stepsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        matrixATextView.text = ""
        infoLabel.isHidden = true
        warningLabel.isHidden = true
        scalingInfoLabel.isHidden = true
    }
    
    private func generateMatrix() {
        A = (0..<size).map { _ in (0..<size).map { _ in Double.random(in: 1...9) } }
    }
    
    private func updateOutput() {
        matrixSizeInfoLabel.text = "Solving \(size)×\(size) Matrix"
        let viewModel = LUDecompositionViewModel(size: size, showSteps: showSteps, A: A)
        let (L, U, steps, error) = viewModel.decompose()
        let explanation = "Step-by-step LU decomposition cannot be displayed for 6x6 matrices or matrices with a near-zero pivot.\n\nIf a near-zero pivot occurs during LU decomposition, it means the matrix cannot be directly decomposed. Please try with a smaller matrix size or a different matrix.\n\nTip: A zero or near-zero pivot means the matrix is singular or needs row swapping (partial pivoting). Try regenerating the matrix or reducing the size for step-by-step explanation."
        clearOutput()
        if error != nil {
            matrixATextView.text = explanation
            return
        }
        matrixATextView.text = matrixString(A, name: "A")
        // Responsive cell size
        let screenWidth = UIScreen.main.bounds.width
        let horizontalPadding: CGFloat = 32 // 16pt left + 16pt right
        let gridSpacing: CGFloat = 3
        let n = size
        let maxCellSize: CGFloat = 50
        let availableWidth = screenWidth - horizontalPadding - CGFloat(n-1)*gridSpacing
        let cellSize = min(maxCellSize, availableWidth / CGFloat(n))
        let maxGridHeight: CGFloat = 200
        // L grid
        lMatrixGrid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        lMatrixGrid.spacing = gridSpacing
        lMatrixGrid.alignment = .fill
        lMatrixGrid.distribution = .fillEqually
        lMatrixGrid.heightAnchor.constraint(equalToConstant: maxGridHeight).isActive = true
        for (i, row) in L.enumerated() {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = gridSpacing
            rowStack.alignment = .fill
            rowStack.distribution = .fillEqually
            for (j, val) in row.enumerated() {
                let label = UILabel()
                label.text = String(format: "%6.3f", val)
                label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .medium)
                label.textAlignment = .center
                label.backgroundColor = (i == j) ? UIColor.systemBlue.withAlphaComponent(0.15) : .white
                label.layer.borderWidth = 0.5
                label.layer.borderColor = UIColor.systemGray4.cgColor
                label.layer.cornerRadius = 4
                label.clipsToBounds = true
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.4
                label.numberOfLines = 1
                label.widthAnchor.constraint(equalToConstant: cellSize).isActive = true
                rowStack.addArrangedSubview(label)
            }
            lMatrixGrid.addArrangedSubview(rowStack)
        }
        // U grid
        uMatrixGrid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        uMatrixGrid.spacing = gridSpacing
        uMatrixGrid.alignment = .fill
        uMatrixGrid.distribution = .fillEqually
        uMatrixGrid.heightAnchor.constraint(equalToConstant: maxGridHeight).isActive = true
        for (i, row) in U.enumerated() {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = gridSpacing
            rowStack.alignment = .fill
            rowStack.distribution = .fillEqually
            for (j, val) in row.enumerated() {
                let label = UILabel()
                label.text = String(format: "%6.3f", val)
                label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .medium)
                label.textAlignment = .center
                label.backgroundColor = (i == j) ? UIColor.systemGreen.withAlphaComponent(0.15) : .white
                label.layer.borderWidth = 0.5
                label.layer.borderColor = UIColor.systemGray4.cgColor
                label.layer.cornerRadius = 4
                label.clipsToBounds = true
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.4
                label.numberOfLines = 1
                label.widthAnchor.constraint(equalToConstant: cellSize).isActive = true
                rowStack.addArrangedSubview(label)
            }
            uMatrixGrid.addArrangedSubview(rowStack)
        }
        // Scaling info label
        if n >= 4 {
            scalingInfoLabel.isHidden = false
        } else {
            scalingInfoLabel.isHidden = true
        }
        // Info/warning logic
        infoLabel.isHidden = true
        warningLabel.isHidden = true
        stepsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if size == 6 && showSteps {
            warningLabel.text = "⚠️ Due to complexity, only the final L and U matrices are shown for 6×6 systems."
            warningLabel.isHidden = false
        } else if !showSteps {
            infoLabel.text = "Step-by-step breakdown is hidden. Enable ‘Show Steps’ to follow the full LU decomposition process."
            infoLabel.isHidden = false
        } else {
            for (i, step) in steps.enumerated() {
                let stepCard = UIView()
                stepCard.backgroundColor = i % 2 == 0 ? UIColor.systemGray6.withAlphaComponent(0.5) : UIColor.systemGray5.withAlphaComponent(0.5)
                stepCard.layer.cornerRadius = 8
                stepCard.layer.masksToBounds = true
                stepCard.translatesAutoresizingMaskIntoConstraints = false
                
                let stepLabel = UILabel()
                stepLabel.text = "Step \(i+1)"
                stepLabel.font = .boldSystemFont(ofSize: 14)
                stepLabel.textColor = .systemBlue
                stepLabel.numberOfLines = 1
                
                let descLabel = UILabel()
                descLabel.text = englishStepDescription(step)
                descLabel.font = .systemFont(ofSize: 14)
                descLabel.numberOfLines = 0
                descLabel.textColor = step.lowercased().contains("zero pivot") ? .systemRed : .label
                
                let stack = UIStackView(arrangedSubviews: [stepLabel, descLabel])
                stack.axis = .vertical
                stack.spacing = 4
                stack.alignment = .leading
                stack.translatesAutoresizingMaskIntoConstraints = false
                stepCard.addSubview(stack)
                NSLayoutConstraint.activate([
                    stack.topAnchor.constraint(equalTo: stepCard.topAnchor, constant: 10),
                    stack.leadingAnchor.constraint(equalTo: stepCard.leadingAnchor, constant: 12),
                    stack.trailingAnchor.constraint(equalTo: stepCard.trailingAnchor, constant: -12),
                    stack.bottomAnchor.constraint(equalTo: stepCard.bottomAnchor, constant: -10)
                ])
                stepsStack.addArrangedSubview(stepCard)
            }
        }
    }
    
    private func matrixString(_ M: [[Double]], name: String) -> String {
        var s = "\(name) =\n"
        for (i, row) in M.enumerated() {
            s += "  "
            for (j, val) in row.enumerated() {
                if i == j && name == "L" {
                    // L matrisinin diagonal elemanlarını vurgula
                    s += String(format: "[%6.3f]", val)
                } else {
                    s += String(format: "%7.3f", val)
                }
                if j < row.count - 1 {
                    s += " "
                }
            }
            s += "\n"
        }
        return s
    }
    
    private func createTipsCard() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .systemGray6
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Tips for LU Decomposition"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        cardView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16).isActive = true
        
        let tipsLabel = UILabel()
        tipsLabel.text = "1. Ensure the matrix is square (i.e., the number of rows equals the number of columns).\n2. Choose a pivot element carefully to avoid near-zero pivots.\n3. Check for and handle near-zero pivots during the decomposition process.\n4. Verify the correctness of the decomposition by multiplying L and U."
        tipsLabel.font = .systemFont(ofSize: 14)
        tipsLabel.textColor = .label
        tipsLabel.textAlignment = .left
        tipsLabel.numberOfLines = 0
        cardView.addSubview(tipsLabel)
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        tipsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        tipsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16).isActive = true
        tipsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16).isActive = true
        tipsLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16).isActive = true
        
        return cardView
    }
    
    // Converts technical step string to a student-friendly English explanation
    private func englishStepDescription(_ step: String) -> String {
        if step.contains("Zero pivot") || step.contains("zero pivot") {
            return "Zero pivot found: LU decomposition cannot proceed because a diagonal element is zero. Try a different matrix."
        }
        if step.contains("U[") && step.contains("= A[") {
            return "Calculate U (upper triangular) element by subtracting the sum of L*U from the original matrix A."
        }
        if step.contains("L[") && step.contains("= 1.0") {
            return "Set diagonal element of L to 1."
        }
        if step.contains("L[") && step.contains("/ U[") {
            return "Calculate L (lower triangular) element by dividing the adjusted value by the current U diagonal element."
        }
        return step
    }
} 