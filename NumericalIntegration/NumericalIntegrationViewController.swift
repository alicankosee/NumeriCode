import UIKit

class NumericalIntegrationViewController: BaseViewController {
    private let quizButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Take the Quiz", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Numerical Integration"
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(quizButton)
        NSLayoutConstraint.activate([
            quizButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            quizButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            quizButton.widthAnchor.constraint(equalToConstant: 220),
            quizButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        quizButton.addTarget(self, action: #selector(quizButtonTapped), for: .touchUpInside)
    }

    @objc private func quizButtonTapped() {
        let quizVC = NumericalIntegrationQuizViewController()
        navigationController?.pushViewController(quizVC, animated: true)
    }
} 