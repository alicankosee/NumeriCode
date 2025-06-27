import UIKit

class HomeBannerView: UIView {
    private let imageView = UIImageView(image: UIImage(systemName: "sparkles"))
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let startButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        layer.cornerRadius = 20
        layer.masksToBounds = true

        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit

        titleLabel.text = "NumeriCode"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .label

        descLabel.text = "Master Numerical Methods with interactive modules!"
        descLabel.font = .systemFont(ofSize: 15)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 2

        startButton.setTitle("Hemen Başla", for: .normal)
        startButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 10

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, descLabel, startButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 36),
            imageView.widthAnchor.constraint(equalToConstant: 36),
            startButton.widthAnchor.constraint(equalToConstant: 140),
            startButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
} 