import UIKit

class ErrorLabViewController: BaseViewController {
    
    // MARK: - Properties
    private let lessonButton = UIButton(type: .system)
    private let simulationButton = UIButton(type: .system)
    private let quizButton = UIButton(type: .system)
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Error Lab"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Başla", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureButtons()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            startButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureButtons() {
        let buttonConfigs: [(UIButton, String, String, Selector)] = [
            (lessonButton, "Lesson", "book.fill", #selector(lessonTapped)),
            (simulationButton, "Simulation", "waveform.path.ecg", #selector(simulationTapped)),
            (quizButton, "Quiz", "checkmark.circle.fill", #selector(quizTapped))
        ]
        
        for (button, title, imageName, action) in buttonConfigs {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.image = UIImage(systemName: imageName)
            config.imagePadding = 8
            config.baseBackgroundColor = .systemBlue
            config.baseForegroundColor = .white
            config.cornerStyle = .large
            
            button.configuration = config
            button.addTarget(self, action: action, for: .touchUpInside)
        }
    }
    
    // MARK: - Actions
    @objc private func lessonTapped() {
        let lessonVC = ErrorLabLessonViewController()
        navigationController?.pushViewController(lessonVC, animated: true)
    }
    
    @objc private func simulationTapped() {
        let simulationVC = ErrorLabSimulationViewController()
        navigationController?.pushViewController(simulationVC, animated: true)
    }
    
    @objc private func quizTapped() {
        let quizVC = ErrorLabQuizViewController()
        navigationController?.pushViewController(quizVC, animated: true)
    }
} 