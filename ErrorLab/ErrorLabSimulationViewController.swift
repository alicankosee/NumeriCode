import UIKit

class ErrorLabSimulationViewController: BaseViewController {
    
    // MARK: - Properties
    private let inputStackView = UIStackView()
    private let resultStackView = UIStackView()
    private let iterationSlider = UISlider()
    private let iterationLabel = UILabel()
    private let valueTextField = UITextField()
    private let resultLabel = UILabel()
    private let graphView = UIView() // Will be replaced with actual chart view
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let outputBox = UIView()
    private let outputStackView = UIStackView()
    private let actualValueLabel = UILabel()
    private let approxValueLabel = UILabel()
    private let absErrorLabel = UILabel()
    private let relErrorLabel = UILabel()
    private let evaluationLabel = UILabel()
    private let absErrorFormula = MTMathUILabel()
    private let relErrorFormula = MTMathUILabel()
    private let actualValueField = UITextField()
    private let approxStackView = UIStackView()
    private let addApproxButton = UIButton(type: .contactAdd)
    private let errorTableStack = UIStackView()
    private var approxFields: [UITextField] = []
    private let summaryLabel = UILabel()
    private let formulaLabel = MTMathUILabel()
    private let inputCard = UIView()
    private let tableCard = UIView()
    private let tableScrollView = UIScrollView()
    private let formulaStack = UIStackView()
    private let formulaCaptionLabel = UILabel()
    private let formulaExampleLabel = MTMathUILabel()
    private let errorTypeSegmented = UISegmentedControl(items: ["Absolute Error", "Relative Error", "% Error"])
    private let resetButton = UIButton(type: .system)
    private let barChartView = UIView()
    private let infoButtons: [UIButton] = [UIButton(type: .infoLight), UIButton(type: .infoLight), UIButton(type: .infoLight), UIButton(type: .infoLight)]
    private let errorTypeExplanations = [
        "Absolute Error: |actual - approx|, the direct difference.",
        "Relative Error: |actual - approx| / |actual|, error as a fraction of the actual value.",
        "% Error: 100 × |actual - approx| / |actual|, error as a percentage."
    ]
    private var currentValue: Double = 1.0
    private var iterations: Int = 10
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    private let barChartScrollView = UIScrollView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Error Lab"
        setupUI()
        configureActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        contentStack.axis = .vertical
        contentStack.spacing = 20
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
        
        // Formula section (scrollable, responsive)
        formulaStack.axis = .vertical
        formulaStack.spacing = 10
        formulaStack.alignment = .center
        formulaStack.translatesAutoresizingMaskIntoConstraints = false
        // Main formula
        formulaLabel.latex = "\\text{Absolute Error} = |x - x^*|\\\\ \\text{Relative Error} = \\frac{|x - x^*|}{|x|}"
        formulaLabel.fontSize = 14
        formulaLabel.textAlignment = .center
        formulaLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 32).isActive = true
        // Caption
        formulaCaptionLabel.text = "Relative Error close to 0 means the approximation is very accurate."
        formulaCaptionLabel.font = UIFont.italicSystemFont(ofSize: 13)
        formulaCaptionLabel.textColor = .secondaryLabel
        formulaCaptionLabel.textAlignment = .center
        formulaCaptionLabel.numberOfLines = 0
        formulaCaptionLabel.adjustsFontSizeToFitWidth = true
        formulaCaptionLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 32).isActive = true
        // Example
        formulaExampleLabel.latex = "|3.14 - 3.1416| = 0.0016\\quad\\text{Relative Error} = 0.0005"
        formulaExampleLabel.fontSize = 13
        formulaExampleLabel.textAlignment = .center
        formulaExampleLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 32).isActive = true
        // Stack'e ekle
        [formulaLabel, formulaCaptionLabel, formulaExampleLabel].forEach { formulaStack.addArrangedSubview($0) }
        contentStack.addArrangedSubview(formulaStack)
        
        // Input card
        inputCard.backgroundColor = UIColor.systemGray6
        inputCard.layer.cornerRadius = 12
        inputCard.layer.borderWidth = 1
        inputCard.layer.borderColor = UIColor.systemGray4.cgColor
        inputCard.translatesAutoresizingMaskIntoConstraints = false
        let inputCardStack = UIStackView(arrangedSubviews: [])
        inputCardStack.axis = .vertical
        inputCardStack.spacing = 14
        inputCardStack.alignment = .fill
        inputCardStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Actual Value input
        let actualValueLabel = UILabel()
        actualValueLabel.text = "Actual Value:"
        actualValueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        actualValueField.placeholder = "Enter actual value"
        actualValueField.borderStyle = .roundedRect
        actualValueField.keyboardType = .decimalPad
        actualValueField.text = "1.0"
        let actualStack = UIStackView(arrangedSubviews: [actualValueLabel, actualValueField])
        actualStack.axis = .horizontal
        actualStack.spacing = 10
        actualStack.distribution = .fillEqually
        
        // Approximate Values input
        let approxTitle = UILabel()
        approxTitle.text = "Approximate Values:"
        approxTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        approxStackView.axis = .vertical
        approxStackView.spacing = 8
        approxStackView.alignment = .fill
        
        // Başlangıçta 3 approx alanı
        approxFields.removeAll()
        approxStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for _ in 0..<3 { addApproxField() }
        let approxInputRow = UIStackView(arrangedSubviews: [approxTitle, addApproxButton])
        approxInputRow.axis = .horizontal
        approxInputRow.spacing = 8
        approxInputRow.alignment = .center
        approxInputRow.distribution = .fill
        approxTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        addApproxButton.addTarget(self, action: #selector(addApproxField), for: .touchUpInside)
        
        // Input card stack
        inputCardStack.addArrangedSubview(actualStack)
        inputCardStack.addArrangedSubview(approxInputRow)
        inputCardStack.addArrangedSubview(approxStackView)
        inputCard.addSubview(inputCardStack)
        NSLayoutConstraint.activate([
            inputCardStack.topAnchor.constraint(equalTo: inputCard.topAnchor, constant: 16),
            inputCardStack.leadingAnchor.constraint(equalTo: inputCard.leadingAnchor, constant: 16),
            inputCardStack.trailingAnchor.constraint(equalTo: inputCard.trailingAnchor, constant: -16),
            inputCardStack.bottomAnchor.constraint(equalTo: inputCard.bottomAnchor, constant: -16)
        ])
        contentStack.addArrangedSubview(inputCard)
        
        // Table card
        tableCard.backgroundColor = UIColor.systemGray6
        tableCard.layer.cornerRadius = 12
        tableCard.layer.borderWidth = 1
        tableCard.layer.borderColor = UIColor.systemGray4.cgColor
        tableCard.translatesAutoresizingMaskIntoConstraints = false
        tableScrollView.translatesAutoresizingMaskIntoConstraints = false
        tableScrollView.showsVerticalScrollIndicator = true
        tableScrollView.alwaysBounceVertical = true
        tableCard.addSubview(tableScrollView)
        NSLayoutConstraint.activate([
            tableScrollView.topAnchor.constraint(equalTo: tableCard.topAnchor, constant: 12),
            tableScrollView.leadingAnchor.constraint(equalTo: tableCard.leadingAnchor, constant: 12),
            tableScrollView.trailingAnchor.constraint(equalTo: tableCard.trailingAnchor, constant: -12),
            tableScrollView.bottomAnchor.constraint(equalTo: tableCard.bottomAnchor, constant: -12),
            tableScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
        contentStack.addArrangedSubview(tableCard)
        
        // Table stack (vertical)
        errorTableStack.axis = .vertical
        errorTableStack.spacing = 12
        errorTableStack.alignment = .fill
        errorTableStack.translatesAutoresizingMaskIntoConstraints = false
        tableScrollView.addSubview(errorTableStack)
        NSLayoutConstraint.activate([
            errorTableStack.topAnchor.constraint(equalTo: tableScrollView.topAnchor, constant: 16),
            errorTableStack.leadingAnchor.constraint(equalTo: tableScrollView.leadingAnchor, constant: 16),
            errorTableStack.trailingAnchor.constraint(equalTo: tableScrollView.trailingAnchor, constant: -16),
            errorTableStack.bottomAnchor.constraint(equalTo: tableScrollView.bottomAnchor, constant: -16),
            errorTableStack.widthAnchor.constraint(equalTo: tableScrollView.widthAnchor, constant: -32)
        ])
        errorTableStack.isHidden = true
        
        // Summary label
        summaryLabel.font = .boldSystemFont(ofSize: 16)
        summaryLabel.textColor = .label
        summaryLabel.textAlignment = .center
        summaryLabel.numberOfLines = 0
        summaryLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.13)
        summaryLabel.layer.cornerRadius = 8
        summaryLabel.layer.masksToBounds = true
        summaryLabel.isHidden = true
        contentStack.addArrangedSubview(summaryLabel)
        
        // Calculate button
        let calculateButton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Compare"
        config.cornerStyle = .large
        calculateButton.configuration = config
        calculateButton.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(calculateButton)
        
        // Error type selector
        errorTypeSegmented.selectedSegmentIndex = 1
        errorTypeSegmented.addTarget(self, action: #selector(errorTypeChanged), for: .valueChanged)
        contentStack.addArrangedSubview(errorTypeSegmented)
        // Reset button
        resetButton.setTitle("Reset All", for: .normal)
        resetButton.setTitleColor(.systemRed, for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        resetButton.addTarget(self, action: #selector(resetAll), for: .touchUpInside)
        contentStack.addArrangedSubview(resetButton)
        // Bar chart
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        barChartScrollView.translatesAutoresizingMaskIntoConstraints = false
        barChartScrollView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        barChartScrollView.showsHorizontalScrollIndicator = true
        barChartScrollView.alwaysBounceHorizontal = true
        barChartScrollView.addSubview(barChartView)
        contentStack.addArrangedSubview(barChartScrollView)
        
        // --- BOTTOM MARGIN ---
        let bottomSpacer = UIView()
        bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentStack.addArrangedSubview(bottomSpacer)
        
        contentStack.insertArrangedSubview(warningLabel, at: 1)
    }
    
    private func configureActions() {
        iterationSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func sliderValueChanged() {
        iterations = Int(iterationSlider.value)
        iterationLabel.text = "Iterations: \(iterations)"
    }
    
    @objc private func calculateTapped() {
        // Input validation
        var hasError = false
        if actualValueField.text?.isEmpty ?? true || Double(actualValueField.text ?? "") == nil {
            highlightField(actualValueField)
            hasError = true
        } else {
            actualValueField.layer.borderWidth = 0
        }
        for field in approxFields {
            if field.text?.isEmpty ?? true || Double(field.text ?? "") == nil {
                highlightField(field)
                hasError = true
            } else {
                field.layer.borderWidth = 0
            }
        }
        if hasError {
            warningLabel.text = "Please enter valid numbers for all fields."
            warningLabel.isHidden = false
            return
        } else {
            warningLabel.isHidden = true
        }
        // Çoklu approx için tablo
        guard let actualText = actualValueField.text, let actual = Double(actualText) else {
            resultLabel.text = "Please enter a valid actual value"
            errorTableStack.isHidden = true
            return
        }
        var approxValues: [Double] = []
        for field in approxFields {
            if let t = field.text, let v = Double(t) { approxValues.append(v) }
        }
        guard !approxValues.isEmpty else {
            resultLabel.text = "Please enter at least one approximate value"
            errorTableStack.isHidden = true
            return
        }
        // Tabloyu temizle
        errorTableStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // Header
        let header = UIStackView()
        header.axis = .horizontal
        header.alignment = .fill
        header.distribution = .fillEqually
        header.spacing = 4
        let h1 = createTableLabel(text: "Approximate Value", bg: UIColor.systemGray5, isHeader: true)
        let h2 = createTableLabel(text: "Absolute Error", bg: UIColor.systemGray5, isHeader: true)
        let h3 = createTableLabel(text: "Relative Error", bg: UIColor.systemGray5, isHeader: true)
        let h4 = createTableLabel(text: "% Error", bg: UIColor.systemGray5, isHeader: true)
        let h5 = createTableLabel(text: "Feedback", bg: UIColor.systemGray5, isHeader: true)
        // Info buttons
        for (i, btn) in infoButtons.enumerated() { btn.tag = i; btn.addTarget(self, action: #selector(showInfo(_:)), for: .touchUpInside) }
        let headerRow = UIStackView(arrangedSubviews: [h1, h2, h3, h4, h5])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.distribution = .fillEqually
        headerRow.spacing = 4
        for (i, btn) in infoButtons.enumerated() where i < headerRow.arrangedSubviews.count-1 {
            let stack = UIStackView(arrangedSubviews: [headerRow.arrangedSubviews[i], btn])
            stack.axis = .horizontal
            stack.spacing = 2
            stack.alignment = .center
            headerRow.removeArrangedSubview(headerRow.arrangedSubviews[i])
            headerRow.insertArrangedSubview(stack, at: i)
        }
        errorTableStack.addArrangedSubview(headerRow)
        // Satırlar ve feedback
        var minMetric: Double = Double.greatestFiniteMagnitude
        var bestIndex: Int = -1
        var metricValues: [Double] = []
        for (idx, approx) in approxValues.enumerated() {
            let absErr = abs(actual - approx)
            let relErr = absErr / abs(actual)
            let pctErr = relErr * 100
            let metric: Double
            switch errorTypeSegmented.selectedSegmentIndex {
                case 0: metric = absErr
                case 1: metric = relErr
                case 2: metric = pctErr
                default: metric = relErr
            }
            metricValues.append(metric)
            if metric < minMetric { minMetric = metric; bestIndex = idx }
        }
        for (idx, approx) in approxValues.enumerated() {
            let absErr = abs(actual - approx)
            let relErr = absErr / abs(actual)
            let pctErr = relErr * 100
            let metric: Double
            switch errorTypeSegmented.selectedSegmentIndex {
                case 0: metric = absErr
                case 1: metric = relErr
                case 2: metric = pctErr
                default: metric = relErr
            }
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .fill
            row.distribution = .fillEqually
            row.spacing = 4
            let l1 = createTableLabel(text: String(format: "%.4f", approx))
            let l2 = createTableLabel(text: String(format: "%.4f", absErr))
            let l3 = createTableLabel(text: String(format: "%.4f", relErr))
            let l4 = createTableLabel(text: String(format: "%.2f", pctErr))
            let l5 = createTableLabel(text: "", font: .systemFont(ofSize: 15))

            // Feedback ve açıklama
            var feedbackExplanation = ""
            if errorTypeSegmented.selectedSegmentIndex == 0 {
                l5.text = "(abs)"
                l5.textColor = .label
                feedbackExplanation = "Absolute error shows the direct difference."
            } else if errorTypeSegmented.selectedSegmentIndex == 1 {
                if relErr < 0.01 {
                    l5.text = "Excellent"
                    l5.textColor = .systemGreen
                    feedbackExplanation = "This means your approximation is very close to the actual value."
                } else if relErr < 0.05 {
                    l5.text = "Acceptable"
                    l5.textColor = .systemOrange
                    feedbackExplanation = "This is an acceptable approximation, but could be improved. Try to increase the number of decimal places in your approximation."
                } else {
                    l5.text = "Inaccurate"
                    l5.textColor = .systemRed
                    feedbackExplanation = "This approximation is not very accurate. If your relative error is above 0.05, your approximation is not very accurate. Try to improve it by using more precise values."
                }
            } else {
                if pctErr < 1 {
                    l5.text = "Excellent"
                    l5.textColor = .systemGreen
                    feedbackExplanation = "This means your approximation is very close to the actual value."
                } else if pctErr < 5 {
                    l5.text = "Acceptable"
                    l5.textColor = .systemOrange
                    feedbackExplanation = "This is an acceptable approximation, but could be improved. Try to increase the number of decimal places in your approximation."
                } else {
                    l5.text = "Inaccurate"
                    l5.textColor = .systemRed
                    feedbackExplanation = "This approximation is not very accurate. If your percent error is above 5%, your approximation is not very accurate. Try to improve it by using more precise values."
                }
            }

            // Alternating row background
            let bgColor = idx % 2 == 0 ? UIColor.systemGray6 : UIColor.systemGray5
            [l1, l2, l3, l4, l5].forEach { $0.backgroundColor = bgColor }
            row.layer.cornerRadius = 8
            row.layer.masksToBounds = true
            row.layer.borderWidth = 0.5
            row.layer.borderColor = UIColor.systemGray4.cgColor
            if idx == bestIndex {
                row.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.13)
                let bestTag = createTableLabel(text: "Best", font: .systemFont(ofSize: 12, weight: .bold), color: .systemGreen)
                row.addArrangedSubview(bestTag)
            }
            [l1, l2, l3, l4, l5].forEach { row.addArrangedSubview($0) }

            // Açıklama label'ı ekle
            let explanationLabel = UILabel()
            explanationLabel.text = feedbackExplanation
            explanationLabel.font = .systemFont(ofSize: 12)
            explanationLabel.textColor = .secondaryLabel
            explanationLabel.numberOfLines = 0
            explanationLabel.textAlignment = .center

            // Satırın altına açıklama ekle
            let rowWithExplanation = UIStackView(arrangedSubviews: [row, explanationLabel])
            rowWithExplanation.axis = .vertical
            rowWithExplanation.spacing = 2

            errorTableStack.addArrangedSubview(rowWithExplanation)
        }
        errorTableStack.isHidden = false
        errorTableStack.setNeedsLayout()
        errorTableStack.layoutIfNeeded()
        tableScrollView.setNeedsLayout()
        tableScrollView.layoutIfNeeded()
        resultLabel.text = ""
        outputBox.isHidden = true
        // Summary
        if bestIndex >= 0 {
            summaryLabel.text = String(format: "Best Approximation: %.4f (%.4g)", approxValues[bestIndex], minMetric)
            summaryLabel.isHidden = false
        }
        // Bar chart
        drawBarChart(values: metricValues, labels: approxValues.map { String(format: "%.2f", $0) }, bestIndex: bestIndex)
        
        // Dinamik örnek ve açıklama
        if let firstApprox = approxValues.first {
            let absErr = abs(actual - firstApprox)
            let relErr = absErr / abs(actual)
            formulaExampleLabel.latex = String(format: "|%.4f - %.4f| = %.4f\\quad\\text{Relative Error} = %.4f", firstApprox, actual, absErr, relErr)
        } else {
            formulaExampleLabel.latex = "|3.14 - 3.1416| = 0.0016\\quad\\text{Relative Error} = 0.0005"
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func addApproxField() {
        let field = UITextField()
        field.placeholder = "Enter approx value"
        field.borderStyle = .roundedRect
        field.keyboardType = .decimalPad
        field.font = .systemFont(ofSize: 15)
        field.adjustsFontSizeToFitWidth = true
        field.minimumFontSize = 12
        approxFields.append(field)
        approxStackView.addArrangedSubview(field)
    }

    @objc private func errorTypeChanged() {
        calculateTapped()
        errorTableStack.setNeedsLayout()
        errorTableStack.layoutIfNeeded()
        tableScrollView.setNeedsLayout()
        tableScrollView.layoutIfNeeded()
    }

    @objc private func resetAll() {
        let alert = UIAlertController(title: "Reset All", message: "Are you sure you want to clear all fields and results?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
            self.actualValueField.text = ""
            self.approxFields.forEach { $0.text = ""; $0.layer.borderWidth = 0 }
            self.errorTableStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self.errorTableStack.isHidden = true
            self.summaryLabel.isHidden = true
            self.barChartView.setNeedsDisplay()
            self.warningLabel.isHidden = true
        }))
        present(alert, animated: true)
    }

    @objc private func showInfo(_ sender: UIButton) {
        let idx = sender.tag
        let msg: String
        switch idx {
            case 0: msg = "The value you entered as an approximation."
            case 1: msg = errorTypeExplanations[0]
            case 2: msg = errorTypeExplanations[1]
            case 3: msg = errorTypeExplanations[2]
            default: msg = ""
        }
        let alert = UIAlertController(title: "Info", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func highlightField(_ field: UITextField) {
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.systemRed.cgColor
        UIView.animate(withDuration: 0.07, animations: {
            field.transform = CGAffineTransform(translationX: 8, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.07) {
                field.transform = .identity
            }
        }
    }

    private func drawBarChart(values: [Double], labels: [String], bestIndex: Int) {
        barChartView.subviews.forEach { $0.removeFromSuperview() }
        barChartView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        guard !values.isEmpty else { return }
        let barWidth: CGFloat = 32
        let spacing: CGFloat = 20
        let chartHeight: CGFloat = 70
        let chartWidth = max(CGFloat(values.count) * (barWidth + spacing) + 40, barChartScrollView.bounds.width)
        barChartView.frame = CGRect(x: 0, y: 0, width: chartWidth, height: 140)
        barChartScrollView.contentSize = CGSize(width: chartWidth, height: 140)
        let maxVal = values.max() ?? 1
        var worstIndex = 0
        if let maxV = values.max(), let idx = values.firstIndex(of: maxV) { worstIndex = idx }

        // Y-ekseni (referans çizgisi)
        let axisLayer = CALayer()
        axisLayer.backgroundColor = UIColor.systemGray3.cgColor
        axisLayer.frame = CGRect(x: 32, y: 8, width: 1, height: chartHeight)
        barChartView.layer.addSublayer(axisLayer)

        for (i, val) in values.enumerated() {
            let x = CGFloat(i) * (barWidth + spacing) + 40
            let barHeight = CGFloat(val) / CGFloat(maxVal == 0 ? 1 : maxVal) * chartHeight
            let barLayer = CALayer()
            barLayer.frame = CGRect(x: x, y: chartHeight - barHeight + 8, width: barWidth, height: barHeight)
            // Renkler ve etiketler
            if i == bestIndex {
                barLayer.backgroundColor = UIColor.systemGreen.cgColor
            } else if i == worstIndex {
                barLayer.backgroundColor = UIColor.systemRed.cgColor
            } else if val < (errorTypeSegmented.selectedSegmentIndex == 2 ? 1 : 0.01) {
                barLayer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7).cgColor
            } else if val < (errorTypeSegmented.selectedSegmentIndex == 2 ? 5 : 0.05) {
                barLayer.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.7).cgColor
            } else {
                barLayer.backgroundColor = UIColor.systemGray3.cgColor
            }
            barChartView.layer.addSublayer(barLayer)

            // Bar üstüne hata değeri
            let valueLabel = UILabel(frame: CGRect(x: x-8, y: chartHeight - barHeight - 10, width: barWidth+16, height: 16))
            valueLabel.text = String(format: "%.3g", val)
            valueLabel.font = .systemFont(ofSize: 11, weight: .bold)
            valueLabel.textAlignment = .center
            valueLabel.textColor = (i == bestIndex) ? .systemGreen : (i == worstIndex ? .systemRed : .label)
            barChartView.addSubview(valueLabel)

            // Bar altına approx label
            let label = UILabel(frame: CGRect(x: x-8, y: chartHeight + 18, width: barWidth+16, height: 16))
            label.text = labels[i]
            label.font = .systemFont(ofSize: 11)
            label.textAlignment = .center
            barChartView.addSubview(label)

            // Best/Worst etiketi
            if i == bestIndex {
                let bestLabel = UILabel(frame: CGRect(x: x, y: chartHeight - barHeight - 24, width: barWidth, height: 14))
                bestLabel.text = "Best"
                bestLabel.font = .systemFont(ofSize: 10, weight: .bold)
                bestLabel.textColor = .systemGreen
                bestLabel.textAlignment = .center
                barChartView.addSubview(bestLabel)
            }
            if i == worstIndex {
                let worstLabel = UILabel(frame: CGRect(x: x, y: chartHeight - barHeight - 24, width: barWidth, height: 14))
                worstLabel.text = "Worst"
                worstLabel.font = .systemFont(ofSize: 10, weight: .bold)
                worstLabel.textColor = .systemRed
                worstLabel.textAlignment = .center
                barChartView.addSubview(worstLabel)
            }
        }

        // Legend (açıklama)
        let legendLabel = UILabel(frame: CGRect(x: 0, y: chartHeight + 40, width: chartWidth, height: 22))
        legendLabel.text = "🟩 Best   🟧 Acceptable   🟥 Worst   ⬜ Other"
        legendLabel.font = .systemFont(ofSize: 14, weight: .medium)
        legendLabel.textAlignment = .center
        legendLabel.textColor = .label
        legendLabel.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.7)
        barChartView.addSubview(legendLabel)

        // Daha belirgin açıklama
        let explanationLabel = UILabel(frame: CGRect(x: 0, y: chartHeight + 65, width: chartWidth, height: 20))
        explanationLabel.text = "Lower bar = better approximation"
        explanationLabel.font = .boldSystemFont(ofSize: 13)
        explanationLabel.textColor = .systemBlue
        explanationLabel.textAlignment = .center
        barChartView.addSubview(explanationLabel)
    }

    private func createTableLabel(text: String, font: UIFont = .systemFont(ofSize: 15), color: UIColor = .label, bg: UIColor? = nil, isHeader: Bool = false) -> UILabel {
        let label = PaddingLabel()
        label.text = text
        label.font = isHeader ? .boldSystemFont(ofSize: 15) : font
        label.textColor = color
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.textAlignment = .center
        label.textInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        if let bg = bg { label.backgroundColor = bg }
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        return label
    }
}

// PaddingLabel: UILabel alt sınıfı, padding için
class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
} 
