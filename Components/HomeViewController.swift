import UIKit

class HomeViewController: BaseViewController {
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "NumeriCode"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var modulesCollection: UICollectionView = {
        let layout = createCollectionViewLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(ModuleCell.self, forCellWithReuseIdentifier: "ModuleCell")
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()
    
    private let modules: [(type: ModuleType, symbol: String, title: String, description: String, color: UIColor)] = [
        (.numericalDifferentiation, "function", "Numerical Differentiation", "Approximate derivatives numerically", UIColor(hex: "#fe9401")),
        (.numericalIntegration, "integral", "Numerical Integration", "Compute definite integrals", .systemBlue),
        (.linearSystemSolver, "square.grid.3x3.middle.filled", "Linear Systems", "Solve linear equation systems", UIColor(hex: "#af53df")),
        (.luDecomposition, "square.stack.3d.down.right.fill", "LU Decomposition", "Matrix factorization", UIColor(hex: "#5856d5")),
        (.optimization, "chart.line.uptrend.xyaxis", "Optimization", "Find optimal solutions", UIColor(hex: "#ff2c54")),
        (.odeSolver, "arrow.triangle.2.circlepath", "ODE Solver", "Solve differential equations", UIColor(hex: "#30aec7")),
        (.performance, "speedometer", "Performance Analysis", "Analyze algorithm efficiency", .systemOrange),
        (.equationSolver, "x.squareroot", "Equation Solver", "Find roots of equations", UIColor(hex: "#34c758")),
        (.errorLab, "exclamationmark.triangle.fill", "Error Analysis", "Study numerical accuracy", UIColor(hex: "#fe3c2e")),
        (.interpolator, "point.3.filled.connected.trianglepath.dotted", "Interpolation", "Estimate intermediate values", .systemYellow)
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modulesCollection.reloadData()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        [titleLabel, modulesCollection].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            modulesCollection.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            modulesCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modulesCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modulesCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 30, right: 16)
        return layout
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModuleCell", for: indexPath) as! ModuleCell
        let module = modules[indexPath.item]
        let isCompleted = ModuleProgressManager.shared.isCompleted(module: module.type.contentFileName)
        cell.configure(
            symbol: module.symbol,
            title: module.title,
            description: module.description,
            color: module.color,
            completed: isCompleted
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
        let spacing: CGFloat = 12
        let availableWidth = collectionView.bounds.width - insets.left - insets.right - spacing
        let itemWidth = floor(availableWidth / 2)
        return CGSize(width: itemWidth, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let module = modules[indexPath.item]
        let moduleType = module.type
        let lessonVC = LessonViewController(module: moduleType)
        navigationController?.pushViewController(lessonVC, animated: true)
    }
}

// MARK: - ModuleCell
final class ModuleCell: UICollectionViewCell {
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.85
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.85
        return label
    }()
    
    private let badgeView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        contentView.addSubview(badgeView)
        
        // Stack view'a elemanları ekle
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconView.heightAnchor.constraint(equalToConstant: 40),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            
            badgeView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            badgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            badgeView.widthAnchor.constraint(equalToConstant: 24),
            badgeView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
    }
    
    func configure(symbol: String, title: String, description: String, color: UIColor, completed: Bool) {
        if let image = UIImage(systemName: symbol) {
            iconView.image = image
        } else {
            iconView.image = UIImage(systemName: "questionmark.square.fill") // fallback
        }
        titleLabel.text = title
        descriptionLabel.text = description
        contentView.backgroundColor = color
        badgeView.isHidden = !completed
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        contentView.backgroundColor = nil
        badgeView.isHidden = true
    }
    
    func setCompleted(_ isCompleted: Bool) {
        badgeView.isHidden = !isCompleted
    }
}

// Helper extension to determine if a color is dark
extension UIColor {
    var isDark: Bool {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return luma < 0.5
    }
    
    static var customGreen: UIColor {
        return UIColor(red: 52/255, green: 199/255, blue: 88/255, alpha: 1)
    }
}

extension ModuleType {
    var displayName: String {
        switch self {
        case .numericalDifferentiation:
            return "Numerical Differentiation"
        case .numericalIntegration:
            return "Numerical Integration"
        case .linearSystemSolver:
            return "Linear Systems"
        case .luDecomposition:
            return "LU Decomposition"
        case .optimization:
            return "Optimization"
        case .odeSolver:
            return "ODE Solver"
        case .performance:
            return "Performance Analysis"
        case .equationSolver:
            return "Equation Solver"
        case .errorLab:
            return "Error Analysis"
        case .interpolator:
            return "Interpolation"
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}


 
 