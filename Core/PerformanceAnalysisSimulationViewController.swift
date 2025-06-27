import UIKit

struct PerformanceAnalysisViewModel {
    let algorithm: String // "Gauss", "Jacobi", "Gauss-Seidel", "LU"
    let size: Int
    var convergenceHistory: [[Double]] = []
    var errorHistory: [Double] = []
    var executionTime: TimeInterval = 0
    var iterations: Int = 0
    var finalError: Double = 0

    // Simüle edilmiş süreler ve iterasyonlar (örnek)
    mutating func runSimulation() -> [Double] {
        let n = size
        let startTime = CFAbsoluteTimeGetCurrent()
        var result: [Double] = []
        switch algorithm {
        case "Gauss":
            // O(n^3)
            result = (1...n).map { Double($0) * Double($0) * Double($0) * 0.0001 }
            iterations = 1
            finalError = 0.001
        case "LU":
            // O(n^3)
            result = (1...n).map { Double($0) * Double($0) * Double($0) * 0.00009 }
            iterations = 1
            finalError = 0.0008
        case "Jacobi":
            // O(n^2 * iter)
            let iter = 20
            iterations = iter
            convergenceHistory = []
            errorHistory = []
            var x = Array(repeating: 0.0, count: n)
            for k in 0..<iter {
                let prev = x
                for i in 0..<n {
                    x[i] = Double(i+1) + Double(k) * 0.1 + Double.random(in: -0.1...0.1)
                }
                convergenceHistory.append(x)
                let error = sqrt(zip(x, prev).map { pow($0 - $1, 2) }.reduce(0, +))
                errorHistory.append(error)
            }
            finalError = errorHistory.last ?? 0.05
            result = x
        case "Gauss-Seidel":
            let iter = 12
            iterations = iter
            convergenceHistory = []
            errorHistory = []
            var x = Array(repeating: 0.0, count: n)
            for k in 0..<iter {
                let prev = x
                for i in 0..<n {
                    x[i] = Double(i+1) + Double(k) * 0.07 + Double.random(in: -0.07...0.07)
                }
                convergenceHistory.append(x)
                let error = sqrt(zip(x, prev).map { pow($0 - $1, 2) }.reduce(0, +))
                errorHistory.append(error)
            }
            finalError = errorHistory.last ?? 0.03
            result = x
        default:
            result = (1...n).map { Double($0) * Double($0) * 0.0005 }
            iterations = 1
            finalError = 0.002
        }
        executionTime = CFAbsoluteTimeGetCurrent() - startTime
        return result
    }
}

struct AlgorithmResult {
    let name: String
    let executionTime: TimeInterval
    let iterations: Int
    let finalError: Double
    let color: UIColor
}

class PerformanceAnalysisSimulationViewController: UIViewController {
    private let graphView = GraphView()
    private let errorGraphView = GraphView()
    private let algorithmSelector = UISegmentedControl(items: ["Gauss", "Jacobi", "Gauss-Seidel", "LU"])
    private let sizeStepper = UIStepper()
    private let sizeLabel = UILabel()
    private let formulaLabel = UILabel()
    private let legendView = UIView()
    private let comparisonView = UIView()
    private let resultsView = UIView()
    private let summaryView = UIView()
    private let compareAllButton = UIButton(type: .system)
    private let barChartView = UIView()
    
    private var algorithm: String = "Gauss"
    private var size: Int = 10
    private var currentViewModel: PerformanceAnalysisViewModel?
    private var allResults: [AlgorithmResult] = []
    private var isComparisonMode = false
    
    // Scrollable layout için yeni değişkenler
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Performance Analysis"
        setupUI()
        updateDisplay()
    }
    
    private func setupUI() {
        // ScrollView ve StackView ayarları
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Eski view.addSubview yerine stackView'a ekle
        contentStackView.addArrangedSubview(algorithmSelector)
        let sizeStack = UIStackView(arrangedSubviews: [sizeLabel, sizeStepper])
        sizeStack.axis = .horizontal
        sizeStack.spacing = 8
        sizeStack.alignment = .center
        sizeStack.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(sizeStack)
        contentStackView.addArrangedSubview(formulaLabel)
        contentStackView.addArrangedSubview(graphView)
        contentStackView.addArrangedSubview(errorGraphView)
        contentStackView.addArrangedSubview(legendView)
        contentStackView.addArrangedSubview(compareAllButton)
        contentStackView.addArrangedSubview(barChartView)
        contentStackView.addArrangedSubview(resultsView)
        contentStackView.addArrangedSubview(summaryView)
        contentStackView.addArrangedSubview(comparisonView)
        
        // Yükseklik constraintlerini kaldır, sadece grafik ve errorGraphView için sabit yükseklik bırak
        graphView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        errorGraphView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        legendView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        compareAllButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        barChartView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        summaryView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        comparisonView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        // resultsView için yükseklik constraintini kaldır
        
        algorithmSelector.selectedSegmentIndex = 0
        algorithmSelector.addTarget(self, action: #selector(algorithmChanged), for: .valueChanged)
        algorithmSelector.translatesAutoresizingMaskIntoConstraints = false
        
        sizeStepper.minimumValue = 2
        sizeStepper.maximumValue = 30
        sizeStepper.value = Double(size)
        sizeStepper.addTarget(self, action: #selector(sizeChanged), for: .valueChanged)
        sizeStepper.translatesAutoresizingMaskIntoConstraints = false
        
        sizeLabel.text = "n: \(size)"
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        formulaLabel.font = .systemFont(ofSize: 13, weight: .medium)
        formulaLabel.textColor = .label
        formulaLabel.textAlignment = .center
        formulaLabel.numberOfLines = 3
        formulaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        legendView.translatesAutoresizingMaskIntoConstraints = false
        legendView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
        legendView.layer.cornerRadius = 8
        
        comparisonView.translatesAutoresizingMaskIntoConstraints = false
        comparisonView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
        comparisonView.layer.cornerRadius = 8
        
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        resultsView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
        resultsView.layer.cornerRadius = 8
        
        summaryView.translatesAutoresizingMaskIntoConstraints = false
        summaryView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
        summaryView.layer.cornerRadius = 8
        
        compareAllButton.setTitle("Compare All Algorithms", for: .normal)
        compareAllButton.backgroundColor = .systemBlue
        compareAllButton.setTitleColor(.white, for: .normal)
        compareAllButton.layer.cornerRadius = 8
        compareAllButton.addTarget(self, action: #selector(compareAllTapped), for: .touchUpInside)
        compareAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.backgroundColor = .clear
    }
    
    @objc private func algorithmChanged() {
        let algorithms = ["Gauss", "Jacobi", "Gauss-Seidel", "LU"]
        algorithm = algorithms[algorithmSelector.selectedSegmentIndex]
        isComparisonMode = false
        updateDisplay()
    }
    
    @objc private func sizeChanged() {
        size = Int(sizeStepper.value)
        sizeLabel.text = "n: \(size)"
        isComparisonMode = false
        updateDisplay()
    }
    
    @objc private func compareAllTapped() {
        isComparisonMode = true
        runAllAlgorithms()
        updateComparisonDisplay()
    }
    
    private func runAllAlgorithms() {
        let algorithms = ["Gauss", "Jacobi", "Gauss-Seidel", "LU"]
        let colors: [UIColor] = [.systemBlue, .systemRed, .systemGreen, .systemOrange]
        
        allResults.removeAll()
        
        for (index, alg) in algorithms.enumerated() {
            var viewModel = PerformanceAnalysisViewModel(algorithm: alg, size: size)
            _ = viewModel.runSimulation()
            
            let result = AlgorithmResult(
                name: alg,
                executionTime: viewModel.executionTime,
                iterations: viewModel.iterations,
                finalError: viewModel.finalError,
                color: colors[index]
            )
            allResults.append(result)
        }
    }
    
    private func updateDisplay() {
        var viewModel = PerformanceAnalysisViewModel(algorithm: algorithm, size: size)
        let result = viewModel.runSimulation()
        currentViewModel = viewModel
        
        updateFormula()
        if algorithm == "Gauss" || algorithm == "LU" {
            updateDirectGraph(result: result)
            errorGraphView.isHidden = true
            legendView.isHidden = true
        } else {
            updateIterativeGraph()
            errorGraphView.isHidden = false
            legendView.isHidden = false
            updateLegend(variables: size)
        }
        
        if !isComparisonMode {
            updateSingleResultDisplay(viewModel: viewModel)
        }
    }
    
    private func updateSingleResultDisplay(viewModel: PerformanceAnalysisViewModel) {
        updateBarChart([viewModel])
        updateResultsView([viewModel])
        updateSummaryView(viewModel)
    }
    
    private func updateComparisonDisplay() {
        updateBarChart(allResults)
        updateResultsView(allResults)
        updateSummaryView(nil)
    }
    
    private func updateFormula() {
        switch algorithm {
        case "Gauss":
            formulaLabel.text = "Gaussian Elimination: Ax = b → Ux = c"
        case "LU":
            formulaLabel.text = "LU Decomposition: PA = LU, Ly = Pb, Ux = y"
        case "Jacobi":
            formulaLabel.text = "Jacobi: xᵢ⁽ᵏ⁺¹⁾ = (bᵢ - Σ₍ⱼ≠ᵢ₎ aᵢⱼ xⱼ⁽ᵏ⁾)/aᵢᵢ"
        case "Gauss-Seidel":
            formulaLabel.text = "G-Seidel: xᵢ⁽ᵏ⁺¹⁾ = (bᵢ - Σ₍ⱼ<ᵢ₎ aᵢⱼ xⱼ⁽ᵏ⁺¹⁾ - Σ₍ⱼ>ᵢ₎ aᵢⱼ xⱼ⁽ᵏ⁾)/aᵢᵢ"
        default:
            formulaLabel.text = ""
        }
    }
    
    private func updateDirectGraph(result: [Double]) {
        let points = result.enumerated().map { CGPoint(x: Double($0.offset), y: $0.element) }
        graphView.configure(
            function: { x in
                let idx = Int(round(x))
                return (idx >= 0 && idx < result.count) ? result[idx] : 0
            },
            xRange: 0...Double(result.count-1),
            yRange: (result.min() ?? 0)...(result.max() ?? 1),
            points: points
        )
    }
    
    private func updateIterativeGraph() {
        guard let viewModel = currentViewModel, !viewModel.convergenceHistory.isEmpty else { return }
        let iterations = viewModel.convergenceHistory.count
        let variables = viewModel.convergenceHistory[0].count
        var functions: [(Double) -> Double] = []
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemTeal]
        for i in 0..<variables {
            let function: (Double) -> Double = { iteration in
                let idx = Int(iteration)
                if idx >= 0 && idx < viewModel.convergenceHistory.count {
                    return viewModel.convergenceHistory[idx][i]
                }
                return 0
            }
            functions.append(function)
        }
        let xRange = 0.0...Double(iterations - 1)
        let allValues = viewModel.convergenceHistory.flatMap { $0 }
        let yRange = (allValues.min() ?? 0)...(allValues.max() ?? 1)
        graphView.configureWithMultipleFunctions(
            functions: functions,
            xRange: xRange,
            yRange: yRange,
            colors: Array(colors.prefix(variables))
        )
        updateErrorGraph()
    }
    
    private func updateErrorGraph() {
        guard let viewModel = currentViewModel, !viewModel.errorHistory.isEmpty else { return }
        let iterations = viewModel.errorHistory.count
        let errorFunction: (Double) -> Double = { iteration in
            let idx = Int(iteration)
            if idx >= 0 && idx < viewModel.errorHistory.count {
                return viewModel.errorHistory[idx]
            }
            return 0
        }
        let xRange = 0.0...Double(iterations - 1)
        let yRange = 0.0...(viewModel.errorHistory.max() ?? 1)
        errorGraphView.configure(
            function: errorFunction,
            xRange: xRange,
            yRange: yRange
        )
    }
    
    private func updateLegend(variables: Int) {
        legendView.subviews.forEach { $0.removeFromSuperview() }
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemTeal]
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        legendView.addSubview(stackView)
        for i in 0..<variables {
            let legendItem = UIView()
            legendItem.translatesAutoresizingMaskIntoConstraints = false
            let colorView = UIView()
            colorView.backgroundColor = colors[i % colors.count]
            colorView.layer.cornerRadius = 3
            colorView.translatesAutoresizingMaskIntoConstraints = false
            legendItem.addSubview(colorView)
            let label = UILabel()
            label.text = "x\(i+1)"
            label.font = .systemFont(ofSize: 10, weight: .regular)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            legendItem.addSubview(label)
            NSLayoutConstraint.activate([
                colorView.leadingAnchor.constraint(equalTo: legendItem.leadingAnchor, constant: 1),
                colorView.centerYAnchor.constraint(equalTo: legendItem.centerYAnchor),
                colorView.widthAnchor.constraint(equalToConstant: 10),
                colorView.heightAnchor.constraint(equalToConstant: 10),
                label.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 1),
                label.trailingAnchor.constraint(equalTo: legendItem.trailingAnchor, constant: -1),
                label.centerYAnchor.constraint(equalTo: legendItem.centerYAnchor)
            ])
            stackView.addArrangedSubview(legendItem)
        }
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: legendView.topAnchor, constant: 1),
            stackView.leadingAnchor.constraint(equalTo: legendView.leadingAnchor, constant: 1),
            stackView.trailingAnchor.constraint(equalTo: legendView.trailingAnchor, constant: -1),
            stackView.bottomAnchor.constraint(equalTo: legendView.bottomAnchor, constant: -1)
        ])
    }
    
    private func updateBarChart(_ results: [Any]) {
        barChartView.subviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.text = "Performance Comparison"
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        barChartView.addSubview(titleLabel)
        
        let chartContainer = UIView()
        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        barChartView.addSubview(chartContainer)
        
        // Metrics labels
        let timeLabel = UILabel()
        timeLabel.text = "Time"
        timeLabel.font = .systemFont(ofSize: 10, weight: .medium)
        timeLabel.textAlignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.addSubview(timeLabel)
        
        let iterLabel = UILabel()
        iterLabel.text = "Iterations"
        iterLabel.font = .systemFont(ofSize: 10, weight: .medium)
        iterLabel.textAlignment = .center
        iterLabel.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.addSubview(iterLabel)
        
        let errorLabel = UILabel()
        errorLabel.text = "Error"
        errorLabel.font = .systemFont(ofSize: 10, weight: .medium)
        errorLabel.textAlignment = .center
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: barChartView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: barChartView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: barChartView.trailingAnchor, constant: -8),
            
            chartContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            chartContainer.leadingAnchor.constraint(equalTo: barChartView.leadingAnchor, constant: 8),
            chartContainer.trailingAnchor.constraint(equalTo: barChartView.trailingAnchor, constant: -8),
            chartContainer.bottomAnchor.constraint(equalTo: barChartView.bottomAnchor, constant: -8),
            
            timeLabel.topAnchor.constraint(equalTo: chartContainer.topAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor),
            timeLabel.widthAnchor.constraint(equalTo: chartContainer.widthAnchor, multiplier: 0.33),
            
            iterLabel.topAnchor.constraint(equalTo: chartContainer.topAnchor, constant: 4),
            iterLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
            iterLabel.widthAnchor.constraint(equalTo: chartContainer.widthAnchor, multiplier: 0.33),
            
            errorLabel.topAnchor.constraint(equalTo: chartContainer.topAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: iterLabel.trailingAnchor),
            errorLabel.widthAnchor.constraint(equalTo: chartContainer.widthAnchor, multiplier: 0.33),
        ])
        
        // Find max values for normalization
        var maxTime: TimeInterval = 0
        var maxIterations = 1
        var maxError: Double = 0
        
        for result in results {
            if let viewModel = result as? PerformanceAnalysisViewModel {
                maxTime = max(maxTime, viewModel.executionTime)
                maxIterations = max(maxIterations, viewModel.iterations)
                maxError = max(maxError, viewModel.finalError)
            } else if let algResult = result as? AlgorithmResult {
                maxTime = max(maxTime, algResult.executionTime)
                maxIterations = max(maxIterations, algResult.iterations)
                maxError = max(maxError, algResult.finalError)
            }
        }
        
        // Create bars for each algorithm
        for (index, result) in results.enumerated() {
            let algorithmName: String
            let time: TimeInterval
            let iterations: Int
            let error: Double
            let color: UIColor
            
            if let viewModel = result as? PerformanceAnalysisViewModel {
                algorithmName = viewModel.algorithm
                time = viewModel.executionTime
                iterations = viewModel.iterations
                error = viewModel.finalError
                color = .systemBlue
            } else if let algResult = result as? AlgorithmResult {
                algorithmName = algResult.name
                time = algResult.executionTime
                iterations = algResult.iterations
                error = algResult.finalError
                color = algResult.color
            } else {
                continue
            }
            
            let algorithmLabel = UILabel()
            algorithmLabel.text = algorithmName
            algorithmLabel.font = .systemFont(ofSize: 10, weight: .medium)
            algorithmLabel.textAlignment = .center
            algorithmLabel.translatesAutoresizingMaskIntoConstraints = false
            chartContainer.addSubview(algorithmLabel)
            
            // Time bar
            let timeBar = UIView()
            timeBar.backgroundColor = color
            timeBar.layer.cornerRadius = 2
            timeBar.translatesAutoresizingMaskIntoConstraints = false
            chartContainer.addSubview(timeBar)
            
            // Iterations bar
            let iterBar = UIView()
            iterBar.backgroundColor = color
            iterBar.layer.cornerRadius = 2
            iterBar.translatesAutoresizingMaskIntoConstraints = false
            chartContainer.addSubview(iterBar)
            
            // Error bar
            let errorBar = UIView()
            errorBar.backgroundColor = color
            errorBar.layer.cornerRadius = 2
            errorBar.translatesAutoresizingMaskIntoConstraints = false
            chartContainer.addSubview(errorBar)
            
            let barHeight: CGFloat = 30
            let timeHeight = maxTime > 0 ? max(CGFloat(time / maxTime) * barHeight, 6) : 6
            let iterHeight = max(CGFloat(iterations) / CGFloat(maxIterations) * barHeight, 6)
            let errorHeight = maxError > 0 ? max(CGFloat(error / maxError) * barHeight, 6) : 6
            
            NSLayoutConstraint.activate([
                algorithmLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8 + CGFloat(index * 25)),
                algorithmLabel.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor),
                algorithmLabel.widthAnchor.constraint(equalTo: chartContainer.widthAnchor, multiplier: 0.33),
                
                timeBar.topAnchor.constraint(equalTo: algorithmLabel.bottomAnchor, constant: 2),
                timeBar.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor, constant: 10),
                timeBar.widthAnchor.constraint(equalTo: chartContainer.widthAnchor, multiplier: 0.3),
                timeBar.heightAnchor.constraint(equalToConstant: timeHeight),
                
                iterBar.topAnchor.constraint(equalTo: algorithmLabel.bottomAnchor, constant: 2),
                iterBar.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 10),
                iterBar.widthAnchor.constraint(equalTo: chartContainer.widthAnchor, multiplier: 0.3),
                iterBar.heightAnchor.constraint(equalToConstant: iterHeight),
                
                errorBar.topAnchor.constraint(equalTo: algorithmLabel.bottomAnchor, constant: 2),
                errorBar.leadingAnchor.constraint(equalTo: iterLabel.trailingAnchor, constant: 10),
                errorBar.widthAnchor.constraint(equalTo: chartContainer.widthAnchor, multiplier: 0.3),
                errorBar.heightAnchor.constraint(equalToConstant: errorHeight),
            ])
        }
    }
    
    private func updateResultsView(_ results: [Any]) {
        resultsView.subviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.text = "Detailed Results"
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        resultsView.addSubview(titleLabel)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        resultsView.addSubview(stackView)
        
        for result in results {
            let algorithmName: String
            let time: TimeInterval
            let iterations: Int
            let error: Double
            let color: UIColor
            
            if let viewModel = result as? PerformanceAnalysisViewModel {
                algorithmName = viewModel.algorithm
                time = viewModel.executionTime
                iterations = viewModel.iterations
                error = viewModel.finalError
                color = .systemBlue
            } else if let algResult = result as? AlgorithmResult {
                algorithmName = algResult.name
                time = algResult.executionTime
                iterations = algResult.iterations
                error = algResult.finalError
                color = algResult.color
            } else {
                continue
            }
            
            let resultCard = UIView()
            resultCard.backgroundColor = color.withAlphaComponent(0.1)
            resultCard.layer.cornerRadius = 8
            resultCard.layer.borderWidth = 1
            resultCard.layer.borderColor = color.withAlphaComponent(0.3).cgColor
            resultCard.translatesAutoresizingMaskIntoConstraints = false
            
            let nameLabel = UILabel()
            nameLabel.text = algorithmName
            nameLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            nameLabel.textColor = color
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            resultCard.addSubview(nameLabel)
            
            let timeLabel = UILabel()
            timeLabel.text = "Time: \(String(format: "%.4f", time))s"
            timeLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            resultCard.addSubview(timeLabel)
            
            let iterLabel = UILabel()
            iterLabel.text = "Iterations: \(iterations)"
            iterLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
            iterLabel.translatesAutoresizingMaskIntoConstraints = false
            resultCard.addSubview(iterLabel)
            
            let errorLabel = UILabel()
            errorLabel.text = "Error: \(String(format: "%.6f", error))"
            errorLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
            errorLabel.translatesAutoresizingMaskIntoConstraints = false
            resultCard.addSubview(errorLabel)
            
            NSLayoutConstraint.activate([
                nameLabel.topAnchor.constraint(equalTo: resultCard.topAnchor, constant: 6),
                nameLabel.leadingAnchor.constraint(equalTo: resultCard.leadingAnchor, constant: 8),
                nameLabel.trailingAnchor.constraint(equalTo: resultCard.trailingAnchor, constant: -8),
                
                timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
                timeLabel.leadingAnchor.constraint(equalTo: resultCard.leadingAnchor, constant: 8),
                timeLabel.trailingAnchor.constraint(equalTo: resultCard.trailingAnchor, constant: -8),
                
                iterLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
                iterLabel.leadingAnchor.constraint(equalTo: resultCard.leadingAnchor, constant: 8),
                iterLabel.trailingAnchor.constraint(equalTo: resultCard.trailingAnchor, constant: -8),
                
                errorLabel.topAnchor.constraint(equalTo: iterLabel.bottomAnchor, constant: 2),
                errorLabel.leadingAnchor.constraint(equalTo: resultCard.leadingAnchor, constant: 8),
                errorLabel.trailingAnchor.constraint(equalTo: resultCard.trailingAnchor, constant: -8),
                errorLabel.bottomAnchor.constraint(equalTo: resultCard.bottomAnchor, constant: -6),
            ])
            
            stackView.addArrangedSubview(resultCard)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: resultsView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: resultsView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: resultsView.trailingAnchor, constant: -8),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: resultsView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: resultsView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: resultsView.bottomAnchor, constant: -8),
        ])
    }
    
    private func updateSummaryView(_ viewModel: PerformanceAnalysisViewModel?) {
        summaryView.subviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.text = "Algorithm Summary"
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryView.addSubview(titleLabel)
        
        let summaryLabel = UILabel()
        summaryLabel.font = .systemFont(ofSize: 11, weight: .regular)
        summaryLabel.numberOfLines = 0
        summaryLabel.textAlignment = .left
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryView.addSubview(summaryLabel)
        
        if let vm = viewModel {
            switch vm.algorithm {
            case "Gauss":
                summaryLabel.text = "Gaussian Elimination: Direct method, O(n³) complexity. Fast for small matrices but computationally expensive for large systems."
            case "LU":
                summaryLabel.text = "LU Decomposition: Direct method, O(n³) complexity. Efficient for multiple right-hand sides and matrix inversion."
            case "Jacobi":
                summaryLabel.text = "Jacobi Method: Iterative method, O(n²) per iteration. Always converges for diagonally dominant matrices but slower convergence."
            case "Gauss-Seidel":
                summaryLabel.text = "Gauss-Seidel: Iterative method, O(n²) per iteration. Faster convergence than Jacobi, uses updated values immediately."
            default:
                summaryLabel.text = "Algorithm analysis complete."
            }
        } else {
            summaryLabel.text = "Comparison mode: All algorithms analyzed. Check individual results for detailed performance metrics."
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: summaryView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -8),
            
            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            summaryLabel.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 8),
            summaryLabel.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -8),
            summaryLabel.bottomAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: -8),
        ])
    }
    
    private func updateComparisonView() {
        comparisonView.subviews.forEach { $0.removeFromSuperview() }
        let titleLabel = UILabel()
        titleLabel.text = "Method Comparison"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        comparisonView.addSubview(titleLabel)
        
        let methods = ["Gauss", "Jacobi", "Gauss-Seidel", "LU"]
        var maxIter = 1
        
        // Find max iterations from allResults
        for result in allResults {
            maxIter = max(maxIter, result.iterations)
        }
        
        let barChartView = UIView()
        barChartView.backgroundColor = .clear
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        comparisonView.addSubview(barChartView)
        
        var bars: [UIView] = []
        for (i, m) in methods.enumerated() {
            let bar = UIView()
            let color: UIColor = [UIColor.systemBlue, UIColor.systemRed, UIColor.systemGreen, UIColor.systemOrange][i % 4]
            bar.backgroundColor = color
            bar.layer.cornerRadius = 4
            bar.translatesAutoresizingMaskIntoConstraints = false
            barChartView.addSubview(bar)
            bars.append(bar)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: comparisonView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: comparisonView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: comparisonView.trailingAnchor, constant: -8),
            barChartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            barChartView.leadingAnchor.constraint(equalTo: comparisonView.leadingAnchor, constant: 8),
            barChartView.trailingAnchor.constraint(equalTo: comparisonView.trailingAnchor, constant: -8),
            barChartView.bottomAnchor.constraint(equalTo: comparisonView.bottomAnchor, constant: -8),
            barChartView.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        for (i, m) in methods.enumerated() {
            let height: CGFloat
            if let result = allResults.first(where: { $0.name == m }) {
                height = CGFloat(result.iterations) / CGFloat(maxIter) * 40
            } else {
                height = 4
            }
            NSLayoutConstraint.activate([
                bars[i].leadingAnchor.constraint(equalTo: barChartView.leadingAnchor, constant: CGFloat(20 + i*60)),
                bars[i].bottomAnchor.constraint(equalTo: barChartView.bottomAnchor),
                bars[i].widthAnchor.constraint(equalToConstant: 30),
                bars[i].heightAnchor.constraint(equalToConstant: height)
            ])
        }
    }
} 