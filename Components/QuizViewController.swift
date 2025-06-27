
import UIKit

class QuizViewController: BaseViewController {
    private let quizView = QuizView()
    private let viewModel: QuizViewModel

    init(module: ModuleType) {
        self.viewModel = QuizViewModel()
        super.init(nibName: nil, bundle: nil)
        viewModel.setModule(module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadContent()
    }

    private func setupUI() {
        title = "Quiz"
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
        
        quizView.onRestartTapped = { [weak self] in
            self?.viewModel.loadContent()
    }

        quizView.onTransitionToNext = { [weak self] in
            self?.viewModel.transitionToNextQuestion()
        }
        
        viewModel.onQuestionUpdate = { [weak self] question, index, score in
            guard let question = question else { return }
            self?.quizView.showQuestion(question: question, index: index, score: score)
        }
        
        viewModel.onQuizEnd = { [weak self] score, total in
            self?.quizView.showQuizEnd(score: score, total: total)
        }
    }
}
