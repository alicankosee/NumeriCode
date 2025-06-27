import UIKit

class InterpolatorSimulationViewController: BaseViewController {
    
    // MARK: - Properties
    private let methodSegmentedControl = UISegmentedControl(items: ["Linear", "Polynomial", "Spline"])
    private let pointsTextField = UITextField()
    private let addPointButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)
    private let interpolateButton = UIButton(type: .system)
    private let graphView = GraphView()
    private let resultLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let resetGraphButton = UIButton(type: .system)
    private var pointLabels: [UILabel] = []
    private var points: [(Double, Double)] = []
    
    // Eklenen yeni özellikler:
    private let formulaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    private let xValueTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter x to interpolate"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.widthAnchor.constraint(equalToConstant: 120).isActive = true
        return tf
    }()
    private let yResultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .systemPurple
        label.textAlignment = .center
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()
    private let calculateYButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Calculate y", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        return btn
    }()
    private let pointsTableStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.isHidden = true
        return stack
    }()
    private let legendLabel: UILabel = {
        let label = UILabel()
        label.text = "Blue: Linear   Orange: Polynomial   Purple: Spline   ●: Data Points   ◉: Interpolated Value"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Interpolation"
        setupUI()
        configureActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        contentStack.axis = .vertical
        contentStack.spacing = 16
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
        
        // Configure method selection
        methodSegmentedControl.selectedSegmentIndex = 0
        
        // Configure points input
        let inputStack = createInputStack()
        
        // Configure graph view
        graphView.backgroundColor = .systemGray6
        graphView.layer.cornerRadius = 8
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.xAxisLabel = "x"
        graphView.yAxisLabel = "y"
        graphView.xRange = -5...5
        graphView.yRange = -5...5
        
        // Configure result label
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
        resultLabel.text = "Add points to start interpolation"
        
        // Configure buttons
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 10
        
        var clearConfig = UIButton.Configuration.bordered()
        clearConfig.title = "Clear Points"
        clearConfig.baseForegroundColor = .systemRed
        clearButton.configuration = clearConfig
        
        var interpolateConfig = UIButton.Configuration.filled()
        interpolateConfig.title = "Interpolate"
        interpolateConfig.cornerStyle = .large
        interpolateButton.configuration = interpolateConfig
        interpolateButton.isEnabled = false
        
        // Reset Graph button
        var resetConfig = UIButton.Configuration.bordered()
        resetConfig.title = "Reset Graph"
        resetConfig.baseForegroundColor = .systemOrange
        resetGraphButton.configuration = resetConfig
        
        buttonStack.addArrangedSubview(clearButton)
        buttonStack.addArrangedSubview(interpolateButton)
        buttonStack.addArrangedSubview(resetGraphButton)
        
        // Add everything to content stack
        [
            methodSegmentedControl,
            inputStack,
            buttonStack,
            graphView,
            resultLabel,
            formulaLabel,
            xValueTextField,
            yResultLabel,
            calculateYButton,
            pointsTableStack,
            legendLabel
        ].forEach { contentStack.addArrangedSubview($0) }
        NSLayoutConstraint.activate([
            graphView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    private func createInputStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .fill
        
        pointsTextField.placeholder = "Enter point (x,y)"
        pointsTextField.borderStyle = .roundedRect
        pointsTextField.keyboardType = .decimalPad
        
        var addConfig = UIButton.Configuration.bordered()
        addConfig.title = "Add Point"
        addPointButton.configuration = addConfig
        
        stack.addArrangedSubview(pointsTextField)
        stack.addArrangedSubview(addPointButton)
        
        NSLayoutConstraint.activate([
            addPointButton.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.3)
        ])
        
        return stack
    }
    
    private func configureActions() {
        addPointButton.addTarget(self, action: #selector(addPointTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        interpolateButton.addTarget(self, action: #selector(interpolateTapped), for: .touchUpInside)
        resetGraphButton.addTarget(self, action: #selector(resetGraphTapped), for: .touchUpInside)
        methodSegmentedControl.addTarget(self, action: #selector(methodChanged), for: .valueChanged)
        calculateYButton.addTarget(self, action: #selector(calculateYTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func addPointTapped() {
        guard let text = pointsTextField.text,
              let point = parsePoint(text) else {
            showAlert(title: "Invalid Input", message: "Please enter point in format: x,y")
            return
        }
        
        points.append(point)
        points.sort { $0.0 < $1.0 } // Sort by x-coordinate
        
        updateUI()
        pointsTextField.text = ""
    }
    
    @objc private func clearTapped() {
        points.removeAll()
        updateUI()
    }
    
    @objc private func interpolateTapped() {
        updateGraph()
    }
    
    @objc private func methodChanged() {
        updateGraph()
    }
    
    @objc private func resetGraphTapped() {
        points.removeAll()
        updateGraph()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func calculateYTapped() {
        guard let xText = xValueTextField.text, let x = Double(xText), points.count >= 2 else {
            yResultLabel.text = "Enter a valid x and at least 2 points"
            yResultLabel.textColor = .systemRed
            yResultLabel.isHidden = false
            return
        }
        let method = methodSegmentedControl.selectedSegmentIndex
        let sorted = points.sorted { $0.0 < $1.0 }
        let xs = sorted.map { $0.0 }
        let ys = sorted.map { $0.1 }
        var y: Double = 0
        if method == 0 {
            // Linear
            guard let i = xs.firstIndex(where: { $0 >= x }), i > 0 else {
                yResultLabel.text = "x is out of range"
                yResultLabel.textColor = .systemRed
                yResultLabel.isHidden = false
                return
            }
            let x0 = xs[i-1], x1 = xs[i]
            let y0 = ys[i-1], y1 = ys[i]
            let t = (x - x0) / (x1 - x0)
            y = y0 + t * (y1 - y0)
        } else if method == 1 {
            y = lagrangePolynomial(xs: xs, ys: ys)(x)
        } else {
            let spline = CubicSplineInterpolator(xs: xs, ys: ys)
            y = spline.interpolate(x)
        }
        yResultLabel.text = String(format: "y ≈ %.4f", y)
        yResultLabel.textColor = .systemPurple
        yResultLabel.isHidden = false

        // Grafikte işaretle
        graphView.highlightedPoint = CGPoint(x: x, y: y)
        graphView.setNeedsDisplay()
    }
    
    // MARK: - Helper Methods
    private func parsePoint(_ text: String) -> (Double, Double)? {
        let components = text.split(separator: ",").map(String.init)
        guard components.count == 2,
              let x = Double(components[0].trimmingCharacters(in: .whitespaces)),
              let y = Double(components[1].trimmingCharacters(in: .whitespaces)) else {
            return nil
        }
        return (x, y)
    }
    
    private func updateUI() {
        interpolateButton.isEnabled = points.count >= 2

        // Noktalar tablosunu temizle
        pointsTableStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if points.isEmpty {
            resultLabel.text = "Add points to start interpolation"
            graphView.drawPoints = []
            graphView.function = nil
            removePointLabels()
            graphView.setNeedsDisplay()
            pointsTableStack.isHidden = true
        } else {
            let method = methodSegmentedControl.selectedSegmentIndex
            let methodName = method == 0 ? "Linear" : (method == 1 ? "Polynomial (Lagrange)" : "Cubic Spline")
            resultLabel.text = "Points: " + points.map { "(\($0.0), \($0.1))" }.joined(separator: ", ") + "\nSelected method: \(methodName)"
            updateGraph()

            // Noktalar tablosu başlığı
            let header = UILabel()
            header.text = "Points Table"
            header.font = .boldSystemFont(ofSize: 15)
            pointsTableStack.addArrangedSubview(header)

            // Noktaları tabloya ekle
            for (i, pt) in points.enumerated() {
                let row = UILabel()
                row.text = String(format: "P%d: (%.4f, %.4f)", i+1, pt.0, pt.1)
                row.font = .systemFont(ofSize: 14)
                row.textColor = .label
                pointsTableStack.addArrangedSubview(row)
            }
            pointsTableStack.isHidden = false
        }
    }
    
    private func updateGraph() {
        graphView.drawPoints = points.map { CGPoint(x: $0.0, y: $0.1) }
        removePointLabels()
        addPointLabels()
        guard points.count >= 2 else {
            graphView.function = nil
            graphView.setNeedsDisplay()
            return
        }
        let method = methodSegmentedControl.selectedSegmentIndex
        let sorted = points.sorted { $0.0 < $1.0 }
        let xs = sorted.map { $0.0 }
        let ys = sorted.map { $0.1 }

        // Otomatik aralık ve padding
        let minX = xs.min() ?? -5
        let maxX = xs.max() ?? 5
        let minY = ys.min() ?? -5
        let maxY = ys.max() ?? 5
        let xPad = max(1.0, (maxX - minX) * 0.15)
        let yPad = max(1.0, (maxY - minY) * 0.15)
        graphView.xRange = (minX - xPad)...(maxX + xPad)
        graphView.yRange = (minY - yPad)...(maxY + yPad)

        if method == 0 { // Linear
            graphView.function = { x in
                guard let i = xs.firstIndex(where: { $0 >= x }), i > 0 else { return ys.first ?? 0 }
                let x0 = xs[i-1], x1 = xs[i]
                let y0 = ys[i-1], y1 = ys[i]
                let t = (x - x0) / (x1 - x0)
                return y0 + t * (y1 - y0)
            }
        } else if method == 1 { // Polynomial (Lagrange)
            graphView.function = lagrangePolynomial(xs: xs, ys: ys)
        } else { // Cubic Spline
            let spline = CubicSplineInterpolator(xs: xs, ys: ys)
            graphView.function = { x in spline.interpolate(x) }
        }
        graphView.setNeedsDisplay()
        formulaLabel.isHidden = false
        if method == 0 {
            formulaLabel.text = "Method: Linear Interpolation\nEach interval uses the formula:\n y = y₀ + (x - x₀) * (y₁ - y₀)/(x₁ - x₀)"
        } else if method == 1 {
            // Lagrange polinomu metni
            let xsStr = points.map { String(format: "%.2f", $0.0) }
            let terms = xsStr.enumerated().map { i, xi in
                "L\(i)(x)"
            }.joined(separator: " + ")
            formulaLabel.text = "Method: Polynomial (Lagrange) Interpolation\nP(x) = " + terms + "\n\nLagrange formula:\nP(x) = Σ yᵢ * Π (x - xⱼ)/(xᵢ - xⱼ)"
        } else {
            formulaLabel.text = "Method: Cubic Spline Interpolation\nA smooth cubic polynomial is fit between each pair of points."
        }
    }
    
    private func addPointLabels() {
        for (i, pt) in points.enumerated() {
            let label = UILabel()
            label.text = String(format: "(%.2f, %.2f)", pt.0, pt.1)
            label.font = .systemFont(ofSize: 10)
            label.textColor = .systemBlue
            label.sizeToFit()
            label.backgroundColor = .clear
            label.translatesAutoresizingMaskIntoConstraints = false
            graphView.addSubview(label)
            let cgpt = graphView.convertToPoint(x: pt.0, y: pt.1)
            label.center = CGPoint(x: cgpt.x, y: cgpt.y - 12)
            pointLabels.append(label)
        }
    }
    
    private func removePointLabels() {
        for label in pointLabels { label.removeFromSuperview() }
        pointLabels.removeAll()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Lagrange Polynomial Interpolation
    func lagrangePolynomial(xs: [Double], ys: [Double]) -> (Double) -> Double {
        return { x in
            var result = 0.0
            for i in 0..<xs.count {
                var term = ys[i]
                for j in 0..<xs.count {
                    if i != j {
                        term *= (x - xs[j]) / (xs[i] - xs[j])
                    }
                }
                result += term
            }
            return result
        }
    }
}

struct CubicSplineInterpolator {
    let xs: [Double]
    let ys: [Double]
    private let n: Int
    private let a: [Double]
    private let b: [Double]
    private let c: [Double]
    private let d: [Double]
    init(xs: [Double], ys: [Double]) {
        self.xs = xs
        self.ys = ys
        n = xs.count - 1
        var a = ys
        var b = [Double](repeating: 0, count: n)
        var d = [Double](repeating: 0, count: n)
        var h = [Double](repeating: 0, count: n)
        for i in 0..<n { h[i] = xs[i+1] - xs[i] }
        var alpha = [Double](repeating: 0, count: n)
        for i in 1..<n { alpha[i] = (3/h[i])*(a[i+1]-a[i]) - (3/h[i-1])*(a[i]-a[i-1]) }
        var c = [Double](repeating: 0, count: xs.count)
        var l = [Double](repeating: 1, count: xs.count)
        var mu = [Double](repeating: 0, count: xs.count)
        var z = [Double](repeating: 0, count: xs.count)
        for i in 1..<n {
            l[i] = 2*(xs[i+1]-xs[i-1]) - h[i-1]*mu[i-1]
            mu[i] = h[i]/l[i]
            z[i] = (alpha[i] - h[i-1]*z[i-1])/l[i]
        }
        for j in (0..<n).reversed() {
            c[j] = z[j] - mu[j]*c[j+1]
            b[j] = (a[j+1]-a[j])/h[j] - h[j]*(c[j+1]+2*c[j])/3
            d[j] = (c[j+1]-c[j])/(3*h[j])
        }
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }
    func interpolate(_ x: Double) -> Double {
        var i = xs.count-2
        for j in 0..<(xs.count-1) {
            if x < xs[j+1] { i = j; break }
        }
        let dx = x - xs[i]
        return a[i] + b[i]*dx + c[i]*dx*dx + d[i]*dx*dx*dx
    }
} 