import UIKit

class NumericalIntegrationQuizViewController: BaseViewController {
    private let quizView = QuizView()
    private let viewModel = QuizViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quiz"
        setupQuizView()
        bindViewModel()
        viewModel.setModule(.numericalIntegration)
        viewModel.loadContent()
    }
    
    private func setupQuizView() {
        quizView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quizView)
        NSLayoutConstraint.activate([
            quizView.topAnchor.constraint(equalTo: contentView.topAnchor),
            quizView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quizView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quizView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        quizView.onOptionSelected = { [weak self] selectedIndex in
            self?.viewModel.answerQuestion(selectedIndex: selectedIndex)
        }
        
        viewModel.onQuestionUpdate = { [weak self] question, index, score in
            guard let question = question else { return }
            self?.quizView.showQuestion(question: question, index: index, score: score)
        }
        
        viewModel.onQuizEnd = { [weak self] score, total in
            self?.quizView.showQuizEnd(score: score, total: total)
        }
    }
    
    private func showError(_ message: String) {
        let label = UILabel()
        label.text = message
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
} 