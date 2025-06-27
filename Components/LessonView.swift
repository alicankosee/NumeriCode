import UIKit

class LessonView: UIView {
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.distribution = .equalSpacing
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    // MARK: - Public Methods
    /// title: Başlık, paragraphs: Paragraflar dizisi, formula: Formül (opsiyonel, LaTeX string veya düz metin)
    func configure(title: String, paragraphs: [String], formula: String? = nil) {
        // Önce stack'i temizle
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // İçerik kutusu
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        container.layer.masksToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor)
        ])
        
        // 1. Başlık
        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = title
        titleLabel.accessibilityLabel = "Lesson title"
        stack.addArrangedSubview(titleLabel)
        
        // Eğer paragraflar 4 veya daha fazlaysa, otomatik section header ve bullet list uygula
        if paragraphs.count >= 4 {
            // Section 1: Tanım
            let whatHeader = UILabel()
            whatHeader.font = .preferredFont(forTextStyle: .headline)
            whatHeader.adjustsFontForContentSizeCategory = true
            whatHeader.textColor = .label
            whatHeader.text = "What is this topic?"
            stack.addArrangedSubview(whatHeader)
            
            let whatDesc = UILabel()
            whatDesc.font = .preferredFont(forTextStyle: .body)
            whatDesc.adjustsFontForContentSizeCategory = true
            whatDesc.textColor = .secondaryLabel
            whatDesc.numberOfLines = 0
            whatDesc.lineBreakMode = .byWordWrapping
            whatDesc.text = paragraphs[0]
            stack.addArrangedSubview(whatDesc)
            
            // Section 2: Kullanım Alanları (Use Cases) - bullet list
            let useHeader = UILabel()
            useHeader.font = .preferredFont(forTextStyle: .headline)
            useHeader.adjustsFontForContentSizeCategory = true
            useHeader.textColor = .label
            useHeader.text = "Use Cases"
            stack.addArrangedSubview(useHeader)
            
            // Paragraflardan anahtar kelimelerle bullet list oluştur (örnek: "used to", "applications", "solve", "compute")
            let bulletCandidates = paragraphs[1].components(separatedBy: [",", "."]).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            for item in bulletCandidates {
                let bullet = UILabel()
                bullet.font = .preferredFont(forTextStyle: .body)
                bullet.adjustsFontForContentSizeCategory = true
                bullet.textColor = .secondaryLabel
                bullet.numberOfLines = 0
                bullet.text = "• " + item
                bullet.textAlignment = .left
                bullet.setContentHuggingPriority(.defaultHigh, for: .vertical)
                bullet.translatesAutoresizingMaskIntoConstraints = false
                stack.addArrangedSubview(bullet)
            }
            
            // Section 3: Process
            let processHeader = UILabel()
            processHeader.font = .preferredFont(forTextStyle: .headline)
            processHeader.adjustsFontForContentSizeCategory = true
            processHeader.textColor = .label
            processHeader.text = "Process"
            stack.addArrangedSubview(processHeader)
            
            let processDescs = [paragraphs[2], paragraphs[3]]
            for desc in processDescs {
                let label = UILabel()
                label.font = .preferredFont(forTextStyle: .body)
                label.adjustsFontForContentSizeCategory = true
                label.textColor = .secondaryLabel
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.text = desc
                stack.addArrangedSubview(label)
            }
            
            // Formül render etme - düz metin veya LaTeX kontrolü
            if let formula = formula, !formula.isEmpty {
                let formulaTopSpace = UIView()
                formulaTopSpace.translatesAutoresizingMaskIntoConstraints = false
                formulaTopSpace.heightAnchor.constraint(equalToConstant: 16).isActive = true
                stack.addArrangedSubview(formulaTopSpace)
                
                // LaTeX formülü kontrolü (\\, {, }, ^, _, \frac gibi karakterler varsa)
                let latexKeywords = ["\\", "{", "}", "^", "_", "\\frac", "\\sqrt", "\\sum", "\\int", "\\lim"]
                let isLatexFormula = latexKeywords.contains { formula.contains($0) }
                
                if isLatexFormula {
                    // LaTeX formülü için MTMathUILabel kullan
                    let mathLabel = MTMathUILabel()
                    mathLabel.latex = formula
                    mathLabel.fontSize = 20
                    mathLabel.textAlignment = .center
                    mathLabel.translatesAutoresizingMaskIntoConstraints = false
                    mathLabel.contentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                    mathLabel.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.5)
                    mathLabel.layer.cornerRadius = 8
                    mathLabel.layer.masksToBounds = true
                    stack.addArrangedSubview(mathLabel)
                } else {
                    // Düz metin formülü için normal label kullan
                    let formulaContainer = UIView()
                    formulaContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                    formulaContainer.layer.cornerRadius = 8
                    formulaContainer.layer.masksToBounds = true
                    formulaContainer.translatesAutoresizingMaskIntoConstraints = false
                    
                    let formulaLabel = UILabel()
                    formulaLabel.text = formula
                    formulaLabel.font = .systemFont(ofSize: 18, weight: .medium)
                    formulaLabel.textColor = .systemBlue
                    formulaLabel.textAlignment = .center
                    formulaLabel.numberOfLines = 0
                    formulaLabel.lineBreakMode = .byWordWrapping
                    formulaLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    formulaContainer.addSubview(formulaLabel)
                    NSLayoutConstraint.activate([
                        formulaLabel.topAnchor.constraint(equalTo: formulaContainer.topAnchor, constant: 12),
                        formulaLabel.leadingAnchor.constraint(equalTo: formulaContainer.leadingAnchor, constant: 16),
                        formulaLabel.trailingAnchor.constraint(equalTo: formulaContainer.trailingAnchor, constant: -16),
                        formulaLabel.bottomAnchor.constraint(equalTo: formulaContainer.bottomAnchor, constant: -12)
                    ])
                    
                    // Formula container'ın genişliğini stack'e sabitle
                    stack.addArrangedSubview(formulaContainer)
                    formulaContainer.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true

                    // Label ayarları
                    formulaLabel.adjustsFontSizeToFitWidth = true
                    formulaLabel.minimumScaleFactor = 0.6
                    formulaLabel.lineBreakMode = .byWordWrapping
                    formulaLabel.numberOfLines = 0
                    formulaLabel.setContentHuggingPriority(.required, for: .vertical)
                    formulaLabel.setContentCompressionResistancePriority(.required, for: .vertical)
                }
                
                let formulaBottomSpace = UIView()
                formulaBottomSpace.translatesAutoresizingMaskIntoConstraints = false
                formulaBottomSpace.heightAnchor.constraint(equalToConstant: 16).isActive = true
                stack.addArrangedSubview(formulaBottomSpace)
            }
            
            // Section 4: Notes & Extensions
            if paragraphs.count > 4 {
                let notesHeader = UILabel()
                notesHeader.font = .preferredFont(forTextStyle: .headline)
                notesHeader.adjustsFontForContentSizeCategory = true
                notesHeader.textColor = .label
                notesHeader.text = "Notes & Extensions"
                stack.addArrangedSubview(notesHeader)
                for i in 4..<paragraphs.count {
                    let label = UILabel()
                    label.font = .preferredFont(forTextStyle: .body)
                    label.adjustsFontForContentSizeCategory = true
                    label.textColor = .secondaryLabel
                    label.numberOfLines = 0
                    label.lineBreakMode = .byWordWrapping
                    label.text = paragraphs[i]
                    stack.addArrangedSubview(label)
                }
            }
        } else {
            // Kısa içerikler için sadece başlık, paragraflar ve formül
            for paragraph in paragraphs {
                let label = UILabel()
                label.font = .preferredFont(forTextStyle: .body)
                label.adjustsFontForContentSizeCategory = true
                label.textColor = .secondaryLabel
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.text = paragraph
                stack.addArrangedSubview(label)
            }
            if let formula = formula, !formula.isEmpty {
                let formulaTopSpace = UIView()
                formulaTopSpace.translatesAutoresizingMaskIntoConstraints = false
                formulaTopSpace.heightAnchor.constraint(equalToConstant: 16).isActive = true
                stack.addArrangedSubview(formulaTopSpace)
                
                // LaTeX formülü kontrolü (\\, {, }, ^, _, \frac gibi karakterler varsa)
                let latexKeywords = ["\\", "{", "}", "^", "_", "\\frac", "\\sqrt", "\\sum", "\\int", "\\lim"]
                let isLatexFormula = latexKeywords.contains { formula.contains($0) }
                
                if isLatexFormula {
                    // LaTeX formülü için MTMathUILabel kullan
                    let mathLabel = MTMathUILabel()
                    mathLabel.latex = formula
                    mathLabel.fontSize = 20
                    mathLabel.textAlignment = .center
                    mathLabel.translatesAutoresizingMaskIntoConstraints = false
                    mathLabel.contentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                    mathLabel.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.5)
                    mathLabel.layer.cornerRadius = 8
                    mathLabel.layer.masksToBounds = true
                    stack.addArrangedSubview(mathLabel)
                } else {
                    // Düz metin formülü için normal label kullan
                    let formulaContainer = UIView()
                    formulaContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                    formulaContainer.layer.cornerRadius = 8
                    formulaContainer.layer.masksToBounds = true
                    formulaContainer.translatesAutoresizingMaskIntoConstraints = false
                    
                    let formulaLabel = UILabel()
                    formulaLabel.text = formula
                    formulaLabel.font = .systemFont(ofSize: 18, weight: .medium)
                    formulaLabel.textColor = .systemBlue
                    formulaLabel.textAlignment = .center
                    formulaLabel.numberOfLines = 0
                    formulaLabel.lineBreakMode = .byWordWrapping
                    formulaLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    formulaContainer.addSubview(formulaLabel)
                    NSLayoutConstraint.activate([
                        formulaLabel.topAnchor.constraint(equalTo: formulaContainer.topAnchor, constant: 12),
                        formulaLabel.leadingAnchor.constraint(equalTo: formulaContainer.leadingAnchor, constant: 16),
                        formulaLabel.trailingAnchor.constraint(equalTo: formulaContainer.trailingAnchor, constant: -16),
                        formulaLabel.bottomAnchor.constraint(equalTo: formulaContainer.bottomAnchor, constant: -12)
                    ])
                    
                    // Formula container'ın genişliğini stack'e sabitle
                    stack.addArrangedSubview(formulaContainer)
                    formulaContainer.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true

                    // Label ayarları
                    formulaLabel.adjustsFontSizeToFitWidth = true
                    formulaLabel.minimumScaleFactor = 0.6
                    formulaLabel.lineBreakMode = .byWordWrapping
                    formulaLabel.numberOfLines = 0
                    formulaLabel.setContentHuggingPriority(.required, for: .vertical)
                    formulaLabel.setContentCompressionResistancePriority(.required, for: .vertical)
                }
                
                let formulaBottomSpace = UIView()
                formulaBottomSpace.translatesAutoresizingMaskIntoConstraints = false
                formulaBottomSpace.heightAnchor.constraint(equalToConstant: 16).isActive = true
                stack.addArrangedSubview(formulaBottomSpace)
            }
        }
        // Kutuyu ana stack'e ekle
        contentStack.addArrangedSubview(container)
        // Dikey padding
        container.layoutMargins = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
    }
} 
 