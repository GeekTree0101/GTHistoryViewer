import UIKit
import SnapKit

class ViewController: UIViewController {
    private let tapper = UITapGestureRecognizer()
    private let leftswipe = UISwipeGestureRecognizer()
    private let rightswipe = UISwipeGestureRecognizer()
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
        self.view.addGestureRecognizer(leftswipe)
        self.view.addGestureRecognizer(rightswipe)
        tapper.addTarget(self, action: #selector(didTapBackground))
        leftswipe.addTarget(self, action: #selector(openHistory))
        leftswipe.direction = .left
        
        rightswipe.addTarget(self, action: #selector(closeHistory))
        rightswipe.direction = .right
        self.attachCountLabel()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        GTHistoryViewer.shared.willMove(self, parent: parent)
    }
    
    private func attachCountLabel() {
        self.view.addSubview(self.countLabelView)
        self.countLabelView.snp.makeConstraints({ make in
            make.center.equalToSuperview()
        })
    }
    
    @objc func didTapBackground() {
        let viewController = ViewController(index: self.index + 1)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func openHistory() {
        GTHistoryViewer.show()
    }
    
    @objc func closeHistory() {
        GTHistoryViewer.hide()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

