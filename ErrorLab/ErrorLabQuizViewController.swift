import UIKit

class ErrorLabQuizViewController: BaseViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let questionLabel = UILabel()
    private let answerStackView = UIStackView()
    private let nextButton = UIButton(type: .system)
    
    private var currentQuestionIndex = 0
    private var score = 0
    
    private let questions = [
        Question(
            text: "Which type of error occurs due to the finite precision of floating-point numbers?",
            options: [
                "Round-off error",
                "Truncation error",
                "Propagation error",
                "Logical error"
            ],
            correctAnswerIndex: 0
        ),
        Question(
            text: "In IEEE 754 double-precision format, how many bits are used for the mantissa?",
            options: [
                "32 bits",
                "52 bits",
                "64 bits",
                "11 bits"
            ],
            correctAnswerIndex: 1
        ),
        Question(
            text: "Which of the following is NOT a good practice for minimizing numerical errors?",
            options: [
                "Using appropriate data types",
                "Sorting calculations by magnitude",
                "Always using double precision",
                "Validating results with different methods"
            ],
            correctAnswerIndex: 2
        )
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showQuestion(at: currentQuestionIndex)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Quiz"
        
        // Configure progress view
        progressView.progress = 0
        progressView.progressTintColor = .systemBlue
        
        // Configure question label
        questionLabel.numberOfLines = 0
        questionLabel.font = .boldSystemFont(ofSize: 18)
        
        // Configure answer stack view
        answerStackView.axis = .vertical
        answerStackView.spacing = 10
        answerStackView.alignment = .fill
        
        // Configure next button
        var config = UIButton.Configuration.filled()
        config.title = "Next Question"
        config.cornerStyle = .large
        nextButton.configuration = config
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        nextButton.isEnabled = false
        
        // Add views to content view
        contentView.addSubview(progressView)
        contentView.addSubview(questionLabel)
        contentView.addSubview(answerStackView)
        contentView.addSubview(nextButton)
        
        // Setup constraints
        progressView.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        answerStackView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: contentView.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            questionLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            answerStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            answerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            answerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nextButton.topAnchor.constraint(equalTo: answerStackView.bottomAnchor, constant: 20),
            nextButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nextButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
            nextButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func showQuestion(at index: Int) {
        guard index < questions.count else {
            showResults()
            return
        }
        
        let question = questions[index]
        questionLabel.text = question.text
        
        // Remove existing answer buttons
        answerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new answer buttons
        for (index, option) in question.options.enumerated() {
            let button = UIButton(type: .system)
            var config = UIButton.Configuration.filled()
            config.title = option
            config.baseBackgroundColor = .systemGray6
            config.baseForegroundColor = .label
            config.cornerStyle = .large
            button.configuration = config
            button.tag = index
            button.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
            answerStackView.addArrangedSubview(button)
        }
        
        // Update progress
        progressView.progress = Float(index) / Float(questions.count)
        nextButton.isEnabled = false
    }
    
    private func showResults() {
        // Remove existing views
        answerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        questionLabel.removeFromSuperview()
        nextButton.removeFromSuperview()
        
        // Show results
        let resultLabel = UILabel()
        resultLabel.text = "Quiz Complete!\nYour score: \(score)/\(questions.count)"
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
        resultLabel.font = .boldSystemFont(ofSize: 24)
        
        let retryButton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Try Again"
        config.cornerStyle = .large
        retryButton.configuration = config
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        
        let resultStack = UIStackView(arrangedSubviews: [resultLabel, retryButton])
        resultStack.axis = .vertical
        resultStack.spacing = 20
        resultStack.alignment = .center
        
        contentView.addSubview(resultStack)
        resultStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resultStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            resultStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    @objc private func answerButtonTapped(_ sender: UIButton) {
        let question = questions[currentQuestionIndex]
        
        // Reset all buttons to default state
        answerStackView.arrangedSubviews.forEach { view in
            guard let button = view as? UIButton else { return }
            var config = button.configuration
            config?.baseBackgroundColor = .systemGray6
            config?.baseForegroundColor = .label
            button.configuration = config
        }
        
        // Update selected button
        var config = sender.configuration
        if sender.tag == question.correctAnswerIndex {
            config?.baseBackgroundColor = .systemGreen
            score += 1
        } else {
            config?.baseBackgroundColor = .systemRed
        }
        config?.baseForegroundColor = .white
        sender.configuration = config
        
        nextButton.isEnabled = true
    }
    
    @objc private func nextButtonTapped() {
        currentQuestionIndex += 1
        showQuestion(at: currentQuestionIndex)
    }
    
    @objc private func retryButtonTapped() {
        currentQuestionIndex = 0
        score = 0
        setupUI()
        showQuestion(at: currentQuestionIndex)
    }
}

// MARK: - Question Model
struct Question {
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
} 