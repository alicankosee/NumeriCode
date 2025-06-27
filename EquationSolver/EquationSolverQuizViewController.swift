import UIKit

class EquationSolverQuizViewController: BaseViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var currentScore = 0
    private var totalQuestions = 0
    
    private let questions: [(String, [String], Int)] = [
        (
            "Which method requires a continuous function and its derivative?",
            [
                "Bisection Method",
                "Newton-Raphson Method",
                "Secant Method",
                "Fixed-Point Iteration"
            ],
            1
        ),
        (
            "What is the convergence rate of the Bisection method?",
            [
                "Linear",
                "Quadratic",
                "Cubic",
                "Logarithmic"
            ],
            0
        ),
        (
            "Which method requires two initial points but no derivatives?",
            [
                "Newton-Raphson Method",
                "Bisection Method",
                "Secant Method",
                "Fixed-Point Iteration"
            ],
            2
        ),
        (
            "What is the main advantage of the Bisection method?",
            [
                "Fastest convergence",
                "No derivatives needed",
                "Guaranteed convergence if conditions met",
                "Works with discontinuous functions"
            ],
            2
        ),
        (
            "Which method typically has the fastest convergence rate?",
            [
                "Bisection Method",
                "Newton-Raphson Method",
                "Secant Method",
                "Fixed-Point Iteration"
            ],
            1
        )
    ]
    
    private let quizView = QuizView()
    private let viewModel = QuizViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quiz"
        setupQuiz()
        bindViewModel()
        viewModel.loadContent()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Root Finding Quiz"
        
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
        
        Keep practicing to improve your understanding of root-finding methods!
        """
        
        let alert = UIAlertController(title: "Quiz Results", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupQuiz() {
        quizView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quizView)
        NSLayoutConstraint.activate([
            quizView.topAnchor.constraint(equalTo: contentView.topAnchor),
            quizView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quizView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quizView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        quizView.onOptionSelected = { [weak self] selectedIndex in
            self?.viewModel.answerQuestion(selectedIndex: selectedIndex)
        }
    }
    
    private func bindViewModel() {
        viewModel.onQuestionUpdate = { [weak self] question, index, score in
            guard let question = question else { return }
            self?.quizView.showQuestion(question: question, index: index, score: score)
        }
        viewModel.onQuizEnd = { [weak self] score, total in
            self?.quizView.showQuizEnd(score: score, total: total)
        }
    }
} 