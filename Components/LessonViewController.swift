import UIKit

class LessonViewController: BaseViewController {
    private let lessonView = LessonView()
    private let viewModel: LessonViewModel
    private let navigationStack = UIStackView()
    private let quizButton = UIButton(type: .system)
    private let simulationButton = UIButton(type: .system)
    private let completeButton = UIButton(type: .system)
    private let uncompleteButton = UIButton(type: .system)
    
    init(module: ModuleType) {
        self.viewModel = LessonViewModel()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCompleteButtons()
    }
    
    private func setupUI() {
        title = "Lesson"
        view.backgroundColor = .systemBackground
        
        // Lesson View
        lessonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lessonView)
        
        // Navigation Stack
        navigationStack.axis = .horizontal
        navigationStack.spacing = 8
        navigationStack.distribution = .fillEqually
        navigationStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationStack)
        
        // Quiz Button
        quizButton.setTitle("Quiz", for: .normal)
        quizButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        quizButton.titleLabel?.numberOfLines = 1
        quizButton.titleLabel?.adjustsFontSizeToFitWidth = true
        quizButton.titleLabel?.minimumScaleFactor = 0.8
        quizButton.backgroundColor = .systemBlue
        quizButton.setTitleColor(.white, for: .normal)
        quizButton.layer.cornerRadius = 12
        quizButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        quizButton.addTarget(self, action: #selector(quizButtonTapped), for: .touchUpInside)
        navigationStack.addArrangedSubview(quizButton)
        
        // Simulation Button
        simulationButton.setTitle("Simulation", for: .normal)
        simulationButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        simulationButton.titleLabel?.numberOfLines = 1
        simulationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        simulationButton.titleLabel?.minimumScaleFactor = 0.8
        simulationButton.backgroundColor = .systemGreen
        simulationButton.setTitleColor(.white, for: .normal)
        simulationButton.layer.cornerRadius = 12
        simulationButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        simulationButton.addTarget(self, action: #selector(simulationButtonTapped), for: .touchUpInside)
        navigationStack.addArrangedSubview(simulationButton)
        
        // Complete Button
        completeButton.setTitle("Complete", for: .normal)
        completeButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        completeButton.titleLabel?.numberOfLines = 1
        completeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        completeButton.titleLabel?.minimumScaleFactor = 0.8
        completeButton.backgroundColor = .systemBlue
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.layer.cornerRadius = 8
        completeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        completeButton.addTarget(self, action: #selector(markCompleteTapped), for: .touchUpInside)
        navigationStack.addArrangedSubview(completeButton)
        
        // Uncomplete Button
        uncompleteButton.setTitle("Unmark", for: .normal)
        uncompleteButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        uncompleteButton.titleLabel?.numberOfLines = 1
        uncompleteButton.titleLabel?.adjustsFontSizeToFitWidth = true
        uncompleteButton.titleLabel?.minimumScaleFactor = 0.8
        uncompleteButton.backgroundColor = .systemGray
        uncompleteButton.setTitleColor(.white, for: .normal)
        uncompleteButton.layer.cornerRadius = 8
        uncompleteButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        uncompleteButton.addTarget(self, action: #selector(unmarkCompleteTapped), for: .touchUpInside)
        navigationStack.addArrangedSubview(uncompleteButton)
        
        NSLayoutConstraint.activate([
            lessonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            lessonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lessonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lessonView.bottomAnchor.constraint(equalTo: navigationStack.topAnchor, constant: -20),
            
            navigationStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            navigationStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            navigationStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            navigationStack.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onContentUpdate = { [weak self] content in
            guard let content = content else { return }
            self?.lessonView.configure(
                title: content.title,
                paragraphs: content.paragraphs,
                formula: content.formula
            )
        }
    }
    
    @objc private func quizButtonTapped() {
        guard let module = viewModel.getCurrentModule() else { return }
        let quizVC = QuizViewController(module: module)
        navigationController?.pushViewController(quizVC, animated: true)
    }
    
    @objc private func simulationButtonTapped() {
        guard let module = viewModel.getCurrentModule() else { return }
        let simulationVC = SimulationViewController(module: module)
        navigationController?.pushViewController(simulationVC, animated: true)
    }
    
    @objc private func markCompleteTapped() {
        guard let module = viewModel.getCurrentModule() else { return }
        ModuleProgressManager.shared.markCompleted(module: module.contentFileName)
        updateCompleteButtons()
        
        // Show success feedback
        let impactFeedback = UINotificationFeedbackGenerator()
        impactFeedback.notificationOccurred(.success)
        
        // Show alert
        let alert = UIAlertController(
            title: "Module Completed! 🎉",
            message: "Great job! You've completed this module. You can now access the Quiz and Simulation to test your knowledge.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Continue", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func unmarkCompleteTapped() {
        guard let module = viewModel.getCurrentModule() else { return }
        ModuleProgressManager.shared.unmarkCompleted(module: module.contentFileName)
        updateCompleteButtons()
        
        // Show success feedback
        let impactFeedback = UINotificationFeedbackGenerator()
        impactFeedback.notificationOccurred(.success)
        
        // Show alert
        let alert = UIAlertController(
            title: "Module Unmarked!",
            message: "This module is now marked as incomplete. You can now access the Quiz and Simulation to test your knowledge.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Continue", style: .default))
        present(alert, animated: true)
    }
    
    private func updateCompleteButtons() {
        guard let module = viewModel.getCurrentModule() else { return }
        let isCompleted = ModuleProgressManager.shared.isCompleted(module: module.contentFileName)
        completeButton.isHidden = isCompleted
        uncompleteButton.isHidden = !isCompleted
        completeButton.isEnabled = !isCompleted
        uncompleteButton.isEnabled = isCompleted
    }
} 