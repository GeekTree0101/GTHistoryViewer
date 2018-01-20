import UIKit
import SnapKit

class TestViewController: UIViewController {
    private let tapper = UITapGestureRecognizer()
    private let index: Int
    
    private lazy var countLabelView = { () -> UILabel in
        let countLabelView = UILabel(frame: .zero)
        countLabelView.font = UIFont.systemFont(ofSize: Const.fontSize, weight: .medium)
        countLabelView.textColor = .white
        countLabelView.text = "\(self.index)"
        countLabelView.isUserInteractionEnabled = false
        return countLabelView
    }()
    
    struct Const {
        static let fontSize: CGFloat = 100.0
    }
    
    required init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.randomColor
        self.title = self.view.backgroundColor?.getColorName()
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapper)
        tapper.addTarget(self, action: #selector(didTapBackground))
        self.attachCountLabel()
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        GTHistoryViewer.shared.didMove(self, parent: parent)
        super.didMove(toParentViewController: parent)
    }

    private func attachCountLabel() {
        self.view.addSubview(self.countLabelView)
        self.countLabelView.snp.makeConstraints({ make in
            make.center.equalToSuperview()
        })
    }
    
    @objc func didTapBackground() {
        let viewController = TestViewController(index: self.index + 1)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

