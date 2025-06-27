import UIKit

class InterpolatorQuizViewController: BaseViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var currentScore = 0
    private var totalQuestions = 0
    
    private let questions: [(String, [String], Int)] = [
        (
            "Which interpolation method is the simplest to implement?",
            [
                "Linear Interpolation",
                "Polynomial Interpolation",
                "Spline Interpolation",
                "Trigonometric Interpolation"
            ],
            0
        ),
        (
            "What is a disadvantage of polynomial interpolation?",
            [
                "Too simple",
                "Runge phenomenon",
                "Requires too many points",
                "Only works with integers"
            ],
            1
        ),
        (
            "Which method is best for smooth, natural-looking curves?",
            [
                "Linear Interpolation",
                "Lagrange Interpolation",
                "Spline Interpolation",
                "Newton Interpolation"
            ],
            2
        ),
        (
            "When should you use linear interpolation?",
            [
                "When you need high accuracy",
                "When data points are far apart",
                "When you need smooth curves",
                "When data points are close together"
            ],
            3
        ),
        (
            "What is an advantage of cubic spline interpolation?",
            [
                "Simplest implementation",
                "Fastest computation",
                "Avoids oscillation issues",
                "Works with any data type"
            ],
            2
        )
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadQuestions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Interpolation Quiz"
        
        // Setup scroll view
        contentView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup stack view
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 30
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func loadQuestions() {
        totalQuestions = questions.count
        
        for (index, (question, answers, _)) in questions.enumerated() {
            let questionView = createQuestionView(
                questionNumber: index + 1,
                questionText: question,
                answers: answers
            )
            stackView.addArrangedSubview(questionView)
        }
        
        // Add submit button
        let submitButton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Submit Quiz"
        config.cornerStyle = .large
        submitButton.configuration = config
        submitButton.addTarget(self, action: #selector(submitQuiz), for: .touchUpInside)
        
        stackView.addArrangedSubview(submitButton)
    }
    
    private func createQuestionView(questionNumber: Int, questionText: String, answers: [String]) -> UIView {
        let containerView = UIView()
        
        let questionLabel = UILabel()
        questionLabel.text = "Q\(questionNumber): \(questionText)"
        questionLabel.numberOfLines = 0
        questionLabel.font = .boldSystemFont(ofSize: 16)
        
        let answersStack = UIStackView()
        answersStack.axis = .vertical
        answersStack.spacing = 10
        
        containerView.addSubview(questionLabel)
        containerView.addSubview(answersStack)
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        answersStack.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, answer) in answers.enumerated() {
            let button = UIButton(type: .system)
            var config = UIButton.Configuration.bordered()
            config.title = answer
            config.baseForegroundColor = .systemBlue
            button.configuration = config
            button.tag = index
            button.addTarget(self, action: #selector(answerSelected(_:)), for: .touchUpInside)
            answersStack.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            answersStack.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10),
            answersStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            answersStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            answersStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    // MARK: - Actions
    @objc private func answerSelected(_ sender: UIButton) {
        // Reset all buttons in the same question group
        if let stackView = sender.superview as? UIStackView {
            for case let button as UIButton in stackView.arrangedSubviews {
                var config = button.configuration
                config?.baseForegroundColor = .systemBlue
                config?.baseBackgroundColor = .clear
                button.configuration = config
            }
        }
        
        // Highlight selected button
        var config = sender.configuration
        config?.baseForegroundColor = .white
        config?.baseBackgroundColor = .systemBlue
        sender.configuration = config
    }
    
    @objc private func submitQuiz() {
        currentScore = 0
        
        // Check each question's answer
        for (questionIndex, (_, _, correctAnswer)) in questions.enumerated() {
            if let questionView = stackView.arrangedSubviews[questionIndex] as? UIView,
               let answersStack = questionView.subviews.last as? UIStackView {
                for case let button as UIButton in answersStack.arrangedSubviews {
                    if button.configuration?.baseBackgroundColor == .systemBlue {
                        if button.tag == correctAnswer {
                            currentScore += 1
                        }
                        break
                    }
                }
            }
        }
        
        // Show result
        let percentage = Double(currentScore) / Double(totalQuestions) * 100
        let message = """
        Your score: \(currentScore)/\(totalQuestions)
        Percentage: \(Int(percentage))%
        
        Keep practicing to improve your understanding of interpolation methods!
        """
        
        let alert = UIAlertController(title: "Quiz Results", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 