import UIKit

class QuizView: UIView {
    private let questionLabel = UILabel()
    private let optionsStack = UIStackView()
    private let scoreLabel = UILabel()
    private let progressLabel = UILabel()
    
    var onOptionSelected: ((Int) -> Void)?
    var onRestartTapped: (() -> Void)?
    var onTransitionToNext: (() -> Void)?
    
    private var currentQuestion: QuizQuestion?
    private var answerButtons: [UIButton] = []
    private var isShowingFeedback = false
    private var correctAnswerIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Question Label
        questionLabel.numberOfLines = 0
        questionLabel.font = .systemFont(ofSize: 18, weight: .medium)
        questionLabel.textAlignment = .left
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(questionLabel)
        
        // Options Stack
        optionsStack.axis = .vertical
        optionsStack.spacing = 12
        optionsStack.distribution = .fillEqually
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(optionsStack)
        
        // Score Label
        scoreLabel.font = .systemFont(ofSize: 16, weight: .bold)
        scoreLabel.textAlignment = .right
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scoreLabel)
        
        // Progress Label
        progressLabel.font = .systemFont(ofSize: 14)
        progressLabel.textAlignment = .left
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            optionsStack.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 24),
            optionsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            optionsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            scoreLabel.topAnchor.constraint(equalTo: optionsStack.bottomAnchor, constant: 24),
            scoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            progressLabel.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor),
            progressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            progressLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20)
        ])
    }
    
    func showQuestion(question: QuizQuestion, index: Int, score: Int) {
        currentQuestion = question
        questionLabel.text = question.question
        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        answerButtons.removeAll()
        isShowingFeedback = false
        
        // Seçenekleri karıştır
        var options = question.options
        let correctAnswer = options[0] // Doğru cevabı sakla
        options.shuffle() // Seçenekleri karıştır
        
        // Doğru cevabın yeni indexini bul ve sakla
        correctAnswerIndex = options.firstIndex(of: correctAnswer) ?? 0
        
        // Seçenekleri butonlara ata
        for (idx, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.backgroundColor = .systemGray6
            button.layer.cornerRadius = 8
            button.tag = idx
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionsStack.addArrangedSubview(button)
            answerButtons.append(button)
            
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        scoreLabel.text = "Score: \(score)"
        progressLabel.text = "Question \(index + 1)"
    }
    
    func showQuizEnd(score: Int, total: Int) {
        questionLabel.text = "Quiz Completed!"
        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        answerButtons.removeAll()
        scoreLabel.text = "Final Score: \(score)/\(total)"
        progressLabel.text = "Completed"
        
        let restartButton = UIButton(type: .system)
        restartButton.setTitle("Restart Quiz", for: .normal)
        restartButton.backgroundColor = .systemBlue
        restartButton.setTitleColor(.white, for: .normal)
        restartButton.layer.cornerRadius = 8
        restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
        optionsStack.addArrangedSubview(restartButton)
        
        restartButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc private func optionTapped(_ sender: UIButton) {
        guard !isShowingFeedback, let question = currentQuestion else { return }
        
        isShowingFeedback = true
        let selectedIndex = sender.tag
        let isCorrect = selectedIndex == correctAnswerIndex
        
        // Disable all buttons during feedback
        answerButtons.forEach { $0.isEnabled = false }
        
        // Show visual feedback with animation
        UIView.animate(withDuration: 0.3, animations: {
            if isCorrect {
                // Correct answer - show green
                sender.backgroundColor = .systemGreen
                sender.setTitleColor(.white, for: .normal)
            } else {
                // Wrong answer - show red for selected, green for correct
                sender.backgroundColor = .systemRed
                sender.setTitleColor(.white, for: .normal)
                
                // Highlight correct answer in green
                if let correctButton = self.answerButtons[safe: self.correctAnswerIndex] {
                    correctButton.backgroundColor = .systemGreen
                    correctButton.setTitleColor(.white, for: .normal)
                }
            }
        })
        
        // Call the callback to update score
        onOptionSelected?(selectedIndex)
        
        // Wait 1 second then transition to next question
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isShowingFeedback = false
            self?.onTransitionToNext?()
        }
    }
    
    @objc private func restartTapped() {
        onRestartTapped?()
    }
}


