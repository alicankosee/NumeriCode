import UIKit

class GraphView: UIView {
    var function: ((Double) -> Double)? {
        didSet { setNeedsDisplay() }
    }
    var xRange: ClosedRange<Double> = -5...5
    var yRange: ClosedRange<Double> = -5...5
    var drawPoints: [CGPoint] = []
    var polygons: [[CGPoint]] = []
    var highlightRadius: CGFloat = 4.0
    var highlightColor: UIColor = .systemBlue
    var multipleFunctions: [(Double) -> Double] = []
    var multipleFunctionColors: [UIColor] = []
    var functionColor: UIColor = .systemBlue
    var pointsColor: UIColor = .systemRed
    var fillColor: UIColor = UIColor.systemGreen.withAlphaComponent(0.18)
    var highlightedPoint: CGPoint? = nil
    var startPoint: CGPoint? = nil
    var endPoint: CGPoint? = nil
    var subintervals: [Double] = []
    var xLabels: [Double] = []
    var showSubintervals: Bool = true
    var showOptimizationPath: Bool = true
    var optimizationMethod: String = "Golden Section"
    var optimizationSteps: [Double] = []
    
    // Multiple functions support for ODE solver
    var secondaryFunction: ((Double) -> Double)? {
        didSet { setNeedsDisplay() }
    }
    var secondaryFunctionColor: UIColor = .systemRed
    var secondaryFunctionStyle: FunctionStyle = .dashed
    
    // Configure with multiple functions for convergence plots
    func configureWithMultipleFunctions(
        functions: [(Double) -> Double],
        xRange: ClosedRange<Double>,
        yRange: ClosedRange<Double>,
        colors: [UIColor]
    ) {
        self.multipleFunctions = functions
        self.multipleFunctionColors = colors
        self.xRange = xRange
        self.yRange = yRange
        setNeedsDisplay()
    }
    
    enum FunctionStyle {
        case solid
        case dashed
        case dotted
    }

    // Fonksiyon ve noktaları güncelle
    func configure(function: @escaping (Double) -> Double, xRange: ClosedRange<Double>, yRange: ClosedRange<Double>? = nil, points: [CGPoint] = []) {
        self.function = function
        self.xRange = xRange
        if let yRange = yRange {
            self.yRange = yRange
        }
        self.drawPoints = points
        setNeedsDisplay()
    }
    
    // Configure secondary function for ODE solver
    func configureWithSecondaryFunction(
        primaryFunction: @escaping (Double) -> Double,
        secondaryFunction: @escaping (Double) -> Double,
        xRange: ClosedRange<Double>,
        yRange: ClosedRange<Double>? = nil,
        points: [CGPoint] = [],
        secondaryColor: UIColor = .systemRed,
        secondaryStyle: FunctionStyle = .dashed
    ) {
        self.function = primaryFunction
        self.secondaryFunction = secondaryFunction
        self.xRange = xRange
        if let yRange = yRange {
            self.yRange = yRange
        }
        self.drawPoints = points
        self.secondaryFunctionColor = secondaryColor
        self.secondaryFunctionStyle = secondaryStyle
        setNeedsDisplay()
    }

    func fillPolygons(_ polygons: [[CGPoint]]) {
        self.polygons = polygons
        setNeedsDisplay()
    }

    var guideLines: [[CGPoint]] = [] {
        didSet { setNeedsDisplay() }
    }
    var guideLineStyle: FunctionStyle = .dashed

    private var stepNumbers: [Int] = []
    func setStepNumbers(_ numbers: [Int]) {
        self.stepNumbers = numbers
        setNeedsDisplay()
    }

    var xAxisLabel: String? = nil
    var yAxisLabel: String? = nil
    var curveDashed: Bool = false
    var curveColor: UIColor = .systemBlue
    var yLogScale: Bool = false

    var graphTitle: String? = nil
    var graphCaption: String? = nil
    var showFinalErrorLabel: Bool = false
    var finalErrorText: String? = nil

    // Animation properties
    private var animationProgress: CGFloat = 1.0
    private var isAnimating: Bool = false
    
    // Drawing constants
    private let margin: CGFloat = 20
    private let pointRadius: CGFloat = 4
    private let lineWidth: CGFloat = 2
    private let dashPattern: [NSNumber] = [4, 4]
    private let gridSpacing: CGFloat = 50
    private let labelFont: UIFont = .systemFont(ofSize: 10)
    
    var showGrid: Bool = false
    var gridStep: Double = 1.0
    
    // Configure with grid support
    func configure(
        function: @escaping (Double) -> Double,
        xRange: ClosedRange<Double>,
        points: [CGPoint] = [],
        showGrid: Bool = false,
        gridStep: Double = 1.0
    ) {
        self.function = function
        self.xRange = xRange
        self.drawPoints = points
        self.showGrid = showGrid
        self.gridStep = gridStep
        
        // Automatically calculate yRange based on function values
        let yValues = stride(from: xRange.lowerBound, through: xRange.upperBound, by: (xRange.upperBound - xRange.lowerBound) / 100)
            .map { function($0) }
        let minY = yValues.min() ?? -5
        let maxY = yValues.max() ?? 5
        let padding = (maxY - minY) * 0.1
        self.yRange = (minY - padding)...(maxY + padding)
        
        setNeedsDisplay()
    }
    
    var showLegend: Bool = false
    var legendLabels: [String] = []
    
    private var noDataOverlay: UIView? = nil
    func showNoDataOverlay(message: String) {
        if noDataOverlay == nil {
            let overlay = UIView(frame: bounds)
            overlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
            overlay.layer.cornerRadius = 12
            let label = UILabel()
            label.text = message
            label.textColor = .systemRed
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            overlay.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -16)
            ])
            addSubview(overlay)
            noDataOverlay = overlay
        }
        noDataOverlay?.isHidden = false
    }
    func hideNoDataOverlay() {
        noDataOverlay?.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Modern UI: shadow and rounded corners
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.systemGray3.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        
        // Clear background
        context.setFillColor(backgroundColor?.cgColor ?? UIColor.systemBackground.cgColor)
        context.fill(rect)
        
        if (function == nil && multipleFunctions.isEmpty && drawPoints.isEmpty) {
            showNoDataOverlay(message: "⚠️ No valid solution to display.")
            return
        } else {
            hideNoDataOverlay()
        }
        
        // Draw grid first
        drawGrid(in: context, rect: rect)
        
        // Draw axes
        drawAxes(in: context, rect: rect)
        
        // Draw functions and points
        if !multipleFunctions.isEmpty {
            drawMultipleFunctions(in: context, rect: rect)
        } else {
            if let function = function {
                drawFunction(function, in: context, rect: rect)
            }
            if let secondaryFunction = secondaryFunction {
                drawSecondaryFunction(secondaryFunction, in: context, rect: rect)
            }
            if !drawPoints.isEmpty {
                drawPoints(in: context, rect: rect)
            }
        }
        
        // Draw highlighted point if exists
        if let point = highlightedPoint {
            let screenPoint = convertToScreenPoint(point, in: rect)
            context.setFillColor(highlightColor.cgColor)
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(2)
            let highlightRect = CGRect(
                x: screenPoint.x - highlightRadius,
                y: screenPoint.y - highlightRadius,
                width: highlightRadius * 2,
                height: highlightRadius * 2
            )
            context.strokeEllipse(in: highlightRect)
            context.fillEllipse(in: highlightRect)
        }
        
        // Draw legend if enabled
        if showLegend && !legendLabels.isEmpty {
            drawLegend(in: context, rect: rect)
        }
    }
    private func drawLegend(in context: CGContext, rect: CGRect) {
        let legendMargin: CGFloat = 12
        let legendPadding: CGFloat = 8
        let legendItemHeight: CGFloat = 24
        let legendItemSpacing: CGFloat = 8
        let symbolWidth: CGFloat = 24
        let symbolMargin: CGFloat = 8
        
        let legendFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: legendFont,
            .foregroundColor: UIColor.label
        ]
        
        // Calculate legend dimensions
        var maxLabelWidth: CGFloat = 0
        for label in legendLabels {
            let size = (label as NSString).size(withAttributes: labelAttributes)
            maxLabelWidth = max(maxLabelWidth, size.width)
        }
        
        let legendWidth = symbolWidth + symbolMargin + maxLabelWidth + 2 * legendPadding
        let legendHeight = CGFloat(legendLabels.count) * legendItemHeight + (CGFloat(legendLabels.count) - 1) * legendItemSpacing + 2 * legendPadding
        
        // Draw legend background
        let legendRect = CGRect(
            x: rect.maxX - legendWidth - legendMargin,
            y: legendMargin,
            width: legendWidth,
            height: legendHeight
        )
        
        let path = UIBezierPath(roundedRect: legendRect, cornerRadius: 8)
        context.setFillColor(UIColor.systemBackground.withAlphaComponent(0.9).cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        // Draw legend items
        for (index, label) in legendLabels.enumerated() {
            let itemY = legendRect.minY + legendPadding + CGFloat(index) * (legendItemHeight + legendItemSpacing)
            
            // Draw color symbol
            let color = index < multipleFunctionColors.count ? multipleFunctionColors[index] : (index == multipleFunctionColors.count ? secondaryFunctionColor : .systemGray)
            let symbolRect = CGRect(
                x: legendRect.minX + legendPadding,
                y: itemY + (legendItemHeight - 4) / 2,
                width: symbolWidth,
                height: 4
            )
            context.setFillColor(color.cgColor)
            context.fill(symbolRect)
            
            // Draw label
            let labelPoint = CGPoint(
                x: symbolRect.maxX + symbolMargin,
                y: itemY + (legendItemHeight - legendFont.lineHeight) / 2
            )
            (label as NSString).draw(at: labelPoint, withAttributes: labelAttributes)
        }
    }
    
    private func drawPoints(in context: CGContext, rect: CGRect) {
        context.setFillColor(pointsColor.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        
        for point in drawPoints {
            let screenPoint = convertToPoint(x: Double(point.x), y: Double(point.y))
            let pointRect = CGRect(
                x: screenPoint.x - pointRadius,
                y: screenPoint.y - pointRadius,
                width: pointRadius * 2,
                height: pointRadius * 2
            )
            context.strokeEllipse(in: pointRect)
            context.fillEllipse(in: pointRect)
        }
    }

    // Fonksiyon koordinatlarını view koordinatına çevir
    func convertToPoint(x: Double, y: Double) -> CGPoint {
        // NaN ve infinite değerleri kontrol et
        guard !x.isNaN && !x.isInfinite && !y.isNaN && !y.isInfinite else {
            // NaN değerler için ekranın dışında bir nokta döndür
            return CGPoint(x: -1000, y: -1000)
        }
        
        // Y aralığının geçerli olduğunu kontrol et
        guard yRange.upperBound > yRange.lowerBound else {
            return CGPoint(x: -1000, y: -1000)
        }
        
        let xPerc = (x - xRange.lowerBound) / (xRange.upperBound - xRange.lowerBound)
        let yPerc = 1.0 - (y - yRange.lowerBound) / (yRange.upperBound - yRange.lowerBound)
        
        // Yüzde değerlerinin geçerli aralıkta olduğunu kontrol et
        let clampedXPerc = max(0.0, min(1.0, xPerc))
        let clampedYPerc = max(0.0, min(1.0, yPerc))
        
        let px = CGFloat(clampedXPerc) * bounds.width
        let py = CGFloat(clampedYPerc) * bounds.height
        
        return CGPoint(x: px, y: py)
    }

    private func drawMultipleFunctions(in context: CGContext, rect: CGRect) {
        let step = (xRange.upperBound - xRange.lowerBound) / Double(rect.width)
        
        for (index, function) in multipleFunctions.enumerated() {
            let color = index < multipleFunctionColors.count ? multipleFunctionColors[index] : .systemBlue
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(2.0)
            
            let path = CGMutablePath()
            var firstPoint = true
            
            for x in stride(from: xRange.lowerBound, through: xRange.upperBound, by: step) {
                let y = function(x)
                let point = convertToPoint(x: x, y: y)
                
                if firstPoint {
                    path.move(to: point)
                    firstPoint = false
                } else {
                    path.addLine(to: point)
                }
            }
            
            context.addPath(path)
            context.strokePath()
        }
    }

    private func drawGuideLines(in context: CGContext, rect: CGRect) {
        context.saveGState()
        let color: UIColor = .systemOrange.withAlphaComponent(0.7)
        color.setStroke()
        context.setLineWidth(2)
        if guideLineStyle == .dashed {
            context.setLineDash(phase: 0, lengths: [6, 4])
        } else {
            context.setLineDash(phase: 0, lengths: [])
        }
        for line in guideLines {
            guard line.count == 2 else { continue }
            let p1 = convertToPoint(x: Double(line[0].x), y: Double(line[0].y))
            let p2 = convertToPoint(x: Double(line[1].x), y: Double(line[1].y))
            context.move(to: p1)
            context.addLine(to: p2)
            context.strokePath()
        }
        context.restoreGState()
    }

    private func drawErrorCurve(in context: CGContext, rect: CGRect) {
        guard drawPoints.count > 1 else { return }
        context.saveGState()
        curveColor.setStroke()
        context.setLineWidth(2)
        if curveDashed {
            context.setLineDash(phase: 0, lengths: [6, 4])
        } else {
            context.setLineDash(phase: 0, lengths: [])
        }
        let path = UIBezierPath()
        for (i, pt) in drawPoints.enumerated() {
            let yVal = yLogScale ? log10(max(pt.y, 1e-10)) : pt.y
            let screenPt = convertToPoint(x: Double(pt.x), y: Double(yVal))
            if i == 0 {
                path.move(to: screenPt)
            } else {
                // Cubic interpolation (smooth)
                let prev = drawPoints[i-1]
                let prevY = yLogScale ? log10(max(prev.y, 1e-10)) : prev.y
                let prevPt = convertToPoint(x: Double(prev.x), y: Double(prevY))
                let midX = (prevPt.x + screenPt.x) / 2
                path.addCurve(to: screenPt,
                              controlPoint1: CGPoint(x: midX, y: prevPt.y),
                              controlPoint2: CGPoint(x: midX, y: screenPt.y))
            }
        }
        path.stroke()
        // Final error label
        if showFinalErrorLabel, let finalText = finalErrorText, let last = drawPoints.last {
            let yVal = yLogScale ? log10(max(last.y, 1e-10)) : last.y
            let lastPt = convertToPoint(x: Double(last.x), y: Double(yVal))
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .bold),
                .foregroundColor: UIColor.systemRed
            ]
            let size = finalText.size(withAttributes: attributes)
            let labelPoint = CGPoint(x: lastPt.x - size.width - 8, y: lastPt.y - size.height - 4)
            finalText.draw(at: labelPoint, withAttributes: attributes)
        }
        context.restoreGState()
    }

    private func drawGrid(in context: CGContext, rect: CGRect) {
        guard showGrid else { return }
        
        let xStart = ceil(xRange.lowerBound / gridStep) * gridStep
        let xEnd = floor(xRange.upperBound / gridStep) * gridStep
        let yStart = ceil(yRange.lowerBound / gridStep) * gridStep
        let yEnd = floor(yRange.upperBound / gridStep) * gridStep
        
        context.setStrokeColor(UIColor.systemGray5.cgColor)
        context.setLineWidth(0.5)
        
        // Draw vertical grid lines
        stride(from: xStart, through: xEnd, by: gridStep).forEach { x in
            let startPoint = convertToPoint(x: x, y: yRange.lowerBound)
            let endPoint = convertToPoint(x: x, y: yRange.upperBound)
            context.move(to: startPoint)
            context.addLine(to: endPoint)
            
            // Draw x-axis labels
            let labelText = String(format: "%.1f", x)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let size = labelText.size(withAttributes: attributes)
            let labelPoint = CGPoint(x: startPoint.x - size.width/2,
                                   y: rect.maxY - margin + 5)
            labelText.draw(at: labelPoint, withAttributes: attributes)
        }
        
        // Draw horizontal grid lines
        stride(from: yStart, through: yEnd, by: gridStep).forEach { y in
            let startPoint = convertToPoint(x: xRange.lowerBound, y: y)
            let endPoint = convertToPoint(x: xRange.upperBound, y: y)
            context.move(to: startPoint)
            context.addLine(to: endPoint)
            
            // Draw y-axis labels
            let labelText = String(format: "%.1f", y)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let size = labelText.size(withAttributes: attributes)
            let labelPoint = CGPoint(x: margin - size.width - 5,
                                   y: startPoint.y - size.height/2)
            labelText.draw(at: labelPoint, withAttributes: attributes)
        }
        
        context.strokePath()
    }

    private func drawAxes(in context: CGContext, rect: CGRect) {
        // Draw x-axis
        let xAxisY = convertToPoint(x: 0, y: 0).y
        UIColor.systemGray3.setStroke()
        context.setLineWidth(1)
        context.move(to: CGPoint(x: rect.minX, y: xAxisY))
        context.addLine(to: CGPoint(x: rect.maxX, y: xAxisY))
        context.strokePath()
        
        // Draw y-axis
        let yAxisX = convertToPoint(x: 0, y: 0).x
        context.move(to: CGPoint(x: yAxisX, y: rect.minY))
        context.addLine(to: CGPoint(x: yAxisX, y: rect.maxY))
        context.strokePath()
    }
    
    private func drawFunction(_ function: (Double) -> Double, in context: CGContext, rect: CGRect) {
        context.setLineWidth(2)
        functionColor.setStroke()
        
        let path = UIBezierPath()
        let step = (xRange.upperBound - xRange.lowerBound) / Double(bounds.width)
        var isFirst = true
        var lastValidPoint: CGPoint?
        
        for pixelX in 0..<Int(bounds.width) {
            let x = xRange.lowerBound + Double(pixelX) * step
            let y = function(x)
            
            if y.isNaN || y.isInfinite {
                if !isFirst {
                    path.move(to: lastValidPoint ?? CGPoint.zero)
                    isFirst = true
                }
                continue
            }
            
            let point = convertToPoint(x: x, y: y)
            
            if isFirst {
                path.move(to: point)
                isFirst = false
            } else {
                path.addLine(to: point)
            }
            lastValidPoint = point
        }
        
        path.stroke()
    }
    
    private func drawSecondaryFunction(_ function: (Double) -> Double, in context: CGContext, rect: CGRect) {
        context.saveGState()
        secondaryFunctionColor.setStroke()
        context.setLineWidth(2)
        
        // Set line style based on secondaryFunctionStyle
        switch secondaryFunctionStyle {
        case .solid:
            context.setLineDash(phase: 0, lengths: [])
        case .dashed:
            context.setLineDash(phase: 0, lengths: [8, 4])
        case .dotted:
            context.setLineDash(phase: 0, lengths: [2, 4])
        }
        
        let path = UIBezierPath()
        let step = (xRange.upperBound - xRange.lowerBound) / Double(bounds.width)
        var isFirst = true
        var lastValidPoint: CGPoint?
        
        for pixelX in 0..<Int(bounds.width) {
            let x = xRange.lowerBound + Double(pixelX) * step
            let y = function(x)
            
            if y.isNaN || y.isInfinite {
                if !isFirst {
                    path.move(to: lastValidPoint ?? CGPoint.zero)
                    isFirst = true
                }
                continue
            }
            
            let point = convertToPoint(x: x, y: y)
            
            if isFirst {
                path.move(to: point)
                isFirst = false
            } else {
                path.addLine(to: point)
            }
            lastValidPoint = point
        }
        
        path.stroke()
        context.restoreGState()
    }
    
    private func drawPolygons(in context: CGContext, rect: CGRect) {
        fillColor.setFill()
        for polygon in polygons {
            let path = UIBezierPath()
            var validPoints: [CGPoint] = []
            
            for p in polygon {
                guard !p.x.isNaN && !p.x.isInfinite && !p.y.isNaN && !p.y.isInfinite else {
                    continue
                }
                let screenPoint = convertToPoint(x: Double(p.x), y: Double(p.y))
                
                guard screenPoint.x >= -500 && screenPoint.y >= -500 else {
                    continue
                }
                
                validPoints.append(screenPoint)
            }
            
            if validPoints.count >= 3 {
                for (i, point) in validPoints.enumerated() {
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.close()
                path.fill()
                
                UIColor.systemGreen.setStroke()
                path.lineWidth = 1
                path.stroke()
            }
        }
    }
    
    private func drawSubintervals(in context: CGContext, rect: CGRect) {
        context.saveGState()
        UIColor.systemGray2.setStroke()
        context.setLineWidth(0.7)
        
        for x in subintervals {
            guard !x.isNaN && !x.isInfinite else { continue }
            let p1 = convertToPoint(x: x, y: yRange.lowerBound)
            let p2 = convertToPoint(x: x, y: yRange.upperBound)
            
            context.move(to: p1)
            context.addLine(to: p2)
            context.strokePath()
        }
        
        // Draw x-axis labels
        if !xLabels.isEmpty {
            let labelFont = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
            let labelColor = UIColor.secondaryLabel
            
            for x in xLabels {
                let screenPoint = convertToPoint(x: x, y: yRange.lowerBound)
                let label = String(format: "%.2g", x)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: labelFont,
                    .foregroundColor: labelColor
                ]
                let size = label.size(withAttributes: attributes)
                let labelRect = CGRect(
                    x: screenPoint.x - size.width/2,
                    y: screenPoint.y + 2,
                    width: size.width,
                    height: size.height
                )
                label.draw(in: labelRect, withAttributes: attributes)
            }
        }
        
        context.restoreGState()
    }

    private func convertToScreenPoint(_ point: CGPoint, in rect: CGRect) -> CGPoint {
        return convertToPoint(x: Double(point.x), y: Double(point.y))
    }
}

