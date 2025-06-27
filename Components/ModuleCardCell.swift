import UIKit

class ModuleCardCell: UICollectionViewCell {
    private let iconView = UIImageView()
    private let iconBg = UIView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let badgeView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.12
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 12

        // Glassmorphism efekti
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blur.frame = contentView.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.layer.cornerRadius = 20
        blur.clipsToBounds = true
        contentView.insertSubview(blur, at: 0)

        iconBg.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        iconBg.layer.cornerRadius = 24
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        descLabel.font = .preferredFont(forTextStyle: .subheadline)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 2

        progressBar.progressTintColor = .systemBlue
        progressBar.trackTintColor = .systemGray5
        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true

        badgeView.backgroundColor = .systemGreen
        badgeView.layer.cornerRadius = 12
        badgeView.isHidden = true
        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.tintColor = .white
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        badgeView.addSubview(checkmark)

        let stack = UIStackView(arrangedSubviews: [iconBg, titleLabel, descLabel, progressBar])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        contentView.addSubview(badgeView)
        iconBg.addSubview(iconView)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            iconBg.heightAnchor.constraint(equalToConstant: 48),
            iconBg.widthAnchor.constraint(equalToConstant: 48),
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            iconView.widthAnchor.constraint(equalToConstant: 32),

            badgeView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            badgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            badgeView.widthAnchor.constraint(equalToConstant: 24),
            badgeView.heightAnchor.constraint(equalToConstant: 24),

            checkmark.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            checkmark.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 16),
            checkmark.heightAnchor.constraint(equalToConstant: 16)
        ])

        setupShadow()
    }

    func configure(icon: UIImage?, title: String, description: String, progress: Float, completed: Bool) {
        iconView.image = icon
        titleLabel.text = title
        descLabel.text = description
        progressBar.progress = progress
        badgeView.isHidden = !completed
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.contentView.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
                self.contentView.layer.shadowRadius = self.isHighlighted ? 20 : 12
            }
        }
    }

    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
    }
} 