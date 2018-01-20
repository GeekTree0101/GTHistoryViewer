import AsyncDisplayKit

protocol GTHistoryViewerProtocol: class {
    func didTapPreviewImage(index: Int)
}

class GTHistoryViewer: ASScrollNode {
    typealias PreviewNode = GTHistoryPreviewNode
    static let shared: GTHistoryViewer = GTHistoryViewer()
    
    fileprivate let showSwipe = UISwipeGestureRecognizer()
    fileprivate let hideSwipe = UISwipeGestureRecognizer()
    fileprivate var didRegistGestureRecognizer: Bool = false
    
    private var historyStack: [PreviewNode] = []
    private let spacing: CGFloat
    private var customShadowAttribute: PreviewNode.Shadow = .init()
    private var customPreviewAttribute: PreviewNode.Preview = .init()
    
    private var stackAreaInsets: UIEdgeInsets = .init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    private var fadeOutDurationAfterPush: TimeInterval = 0.3
    fileprivate struct Const {
        static let defaultSpacing: CGFloat = 10.0
        static let defaultViewerHeight: CGFloat = 200.0
        static let swipeGestureKey: String = "GTHistoryViewer-Gesture"
    }
    
    enum ViewerAlign {
        case top
        case center
        case bottom
    }
    
    init(customShadowAttribute: PreviewNode.Shadow? = nil,
         customPreviewAttribute: PreviewNode.Preview? = nil,
         spacing: CGFloat = Const.defaultSpacing) {
        self.spacing = spacing
        super.init()
        self.showSwipe.addTarget(self, action: #selector(openHistory))
        self.hideSwipe.addTarget(self, action: #selector(closeHistory))
        self.showSwipe.direction = .left
        self.hideSwipe.direction = .right
        self.showSwipe.name = Const.swipeGestureKey
        self.showSwipe.name = Const.swipeGestureKey
        self.scrollableDirections = [.left, .right]
        self.automaticallyManagesContentSize = true
        self.automaticallyManagesSubnodes = true
    }
    
    func didMove(_ presentViewController: UIViewController, parent: UIViewController?) {
        guard self.didRegistGestureRecognizer else {
            print("ERROR: Please register GTHistoryViewer gesture")
            return
        }
        
        if parent != nil {
            // Push new viewcontroller on navigation controller
            let image = captureScreen(presentViewController)
            let previewNode = PreviewNode(image,
                                          index: self.historyStack.count,
                                          shadowAttribute: self.customShadowAttribute,
                                          previewAttribute: self.customPreviewAttribute)
            previewNode.style.spacingBefore = self.spacing
            previewNode.delegate = self
            historyStack.append(previewNode)
            self.setNeedsLayout()
            UIView.animate(withDuration: self.fadeOutDurationAfterPush,
                           animations: {
                            self.view.alpha = 0.0
                            self.scrollToRight()
            }, completion: { _ in
                self.view.removeFromSuperview()
            })
        } else {
            // Pop stack on navigation controller
            _ = self.historyStack.popLast()
            self.setNeedsLayout()
            GTHistoryViewer.hide()
        }
    }
    
    private func scrollToRight() {
        guard self.view.contentSize.width > UIScreen.main.bounds.width,
            let firstNode = self.historyStack.first else { return }
        
        DispatchQueue.main.async {
            var xOffset: CGFloat = (firstNode.calculatedSize.width + self.spacing)
            xOffset *= CGFloat(self.historyStack.count)
            xOffset += (self.spacing * 2)
            let rightOffset = CGPoint(x: xOffset - self.view.bounds.size.width,
                                      y: 0.0)
            self.view.setContentOffset(rightOffset, animated: true)
        }
    }
    
    private func scrollToLeft() {
        DispatchQueue.main.async {
            self.view.setContentOffset(.zero, animated: true)
        }
    }
    
    private func captureScreen(_ presentViewController: UIViewController) -> UIImage? {
        UIGraphicsBeginImageContext(presentViewController.view.frame.size)
        presentViewController.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackAreaLayoutSpec = ASStackLayoutSpec(direction: .horizontal,
                                                    spacing: 0.0,
                                                    justifyContent: .start,
                                                    alignItems: .start,
                                                    children: self.historyStack)
        return ASInsetLayoutSpec(insets: self.stackAreaInsets,
                                 child: stackAreaLayoutSpec)
    }
    
    override func didLoad() {
        super.didLoad()
        self.view.showsHorizontalScrollIndicator = false
        self.view.showsVerticalScrollIndicator = false
    }
}

// MARK: - update attribute
extension GTHistoryViewer {
    @objc private func openHistory() {
        GTHistoryViewer.show()
    }
    
    @objc private func closeHistory() {
        GTHistoryViewer.hide()
    }
    
    private func gestureRegistAvailableCheck(_ view: UIView) -> Bool {
        guard let gestures = view.gestureRecognizers else { return true}
        
        for gesture in gestures where gesture.name == Const.swipeGestureKey {
            print("ERROR: Already regist History Viewer gesture")
            return false
        }
        
        return true
    }
    
    @discardableResult func registGlobalGesture() -> GTHistoryViewer {
        guard let view = UIApplication
            .shared
            .keyWindow?
            .rootViewController?
            .view else { return self }
        
        guard gestureRegistAvailableCheck(view) else { return self }
        
        view.addGestureRecognizer(showSwipe)
        view.addGestureRecognizer(hideSwipe)
        self.didRegistGestureRecognizer = true
        return self
    }
    
    @discardableResult func registGesture(view: UIView) -> GTHistoryViewer {
        guard gestureRegistAvailableCheck(view) else { return self }
        
        view.addGestureRecognizer(showSwipe)
        view.addGestureRecognizer(hideSwipe)
        self.didRegistGestureRecognizer = true
        return self
    }
    
    @discardableResult func unregistGesture(view: UIView?) -> GTHistoryViewer {
        guard let targetView = view else {
            guard let view = UIApplication
                .shared
                .keyWindow?
                .rootViewController?
                .view else { return self }
            
            view.removeGestureRecognizer(showSwipe)
            view.removeGestureRecognizer(hideSwipe)
            
            self.didRegistGestureRecognizer = false
            return self
        }
        
        targetView.removeGestureRecognizer(showSwipe)
        targetView.removeGestureRecognizer(hideSwipe)
        self.didRegistGestureRecognizer = false
        return self
    }
    
    @discardableResult func updatePreviewAttribite(_ block: (inout PreviewNode.Preview) -> Void) -> GTHistoryViewer {
        block(&self.customPreviewAttribute)
        for previewNode in self.historyStack {
            previewNode.setPreviewImageAttribute({ node in
                node.frameColor = self.customPreviewAttribute.frameColor
                node.previewBorderWidth = self.customPreviewAttribute.previewBorderWidth
                node.previewCornerRadius = self.customPreviewAttribute.previewCornerRadius
            })
        }
        return self
    }
    
    @discardableResult func updateShadowAttribute(_ block: (inout PreviewNode.Shadow) -> Void) -> GTHistoryViewer {
        block(&self.customShadowAttribute)
        for previewNode in self.historyStack {
            previewNode.setPreviewShadowAttribute({ node in
                node.shadowOpacity = self.customShadowAttribute.shadowOpacity
                node.shadowColor = self.customShadowAttribute.shadowColor
                node.shadowRadius = self.customShadowAttribute.shadowRadius
                node.shadowOffset = self.customShadowAttribute.shadowOffset
            })
        }
        return self
    }
    
    @discardableResult func updateFadeOutDurationAfterPush(_ duration: TimeInterval) -> GTHistoryViewer {
        self.fadeOutDurationAfterPush = duration
        return self
    }
}

// MARK: - touch event
extension GTHistoryViewer: GTHistoryViewerProtocol {
    func didTapPreviewImage(index: Int) {
        guard let navigationController =
            self.closestViewController as? UINavigationController else {
                return
        }
        
        guard self.historyStack.count > index else { return }
        let targetViewController = navigationController.childViewControllers[index]
        _ = navigationController.popToViewController(targetViewController,
                                 animated: true)
    }
}

// MARK: - external event
extension GTHistoryViewer {
    static func show(_ previewHeight: CGFloat = Const.defaultViewerHeight,
                     align: ViewerAlign = .bottom,
                     duration: TimeInterval = 0.5,
                     delay: TimeInterval = 0.0) {
        guard GTHistoryViewer.shared.view.superview == nil else { return }
        guard let rootViewController = UIApplication
            .shared
            .keyWindow?
            .rootViewController,
            let rootView = rootViewController.view else { return }
        rootViewController.view.addSubnode(GTHistoryViewer.shared)
        GTHistoryViewer.shared.onDidLoad({ node in
            node.view.translatesAutoresizingMaskIntoConstraints = false
            let leadingConstraint = NSLayoutConstraint(item: node.view,
                                                       attribute: NSLayoutAttribute.leading,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: rootView,
                                                       attribute: NSLayoutAttribute.leading,
                                                       multiplier: 1,
                                                       constant: 0)
            
            let tralingConstraint = NSLayoutConstraint(item: node.view,
                                                       attribute: NSLayoutAttribute.trailing,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: rootView,
                                                       attribute: NSLayoutAttribute.trailing,
                                                       multiplier: 1,
                                                       constant: 0)
            
            let heightConstraint = NSLayoutConstraint(item: node.view,
                                                      attribute: NSLayoutAttribute.height,
                                                      relatedBy: NSLayoutRelation.equal,
                                                      toItem: nil,
                                                      attribute: NSLayoutAttribute.height,
                                                      multiplier: 1,
                                                      constant: previewHeight)
            
            var adjustAttribute: NSLayoutAttribute = .bottom
            
            switch align {
            case .top:
                adjustAttribute = .top
            case .center:
                adjustAttribute = .centerY
            case .bottom:
                adjustAttribute = .bottom
            }
            
            let offsetConstraint = NSLayoutConstraint(item: node.view,
                                                  attribute: adjustAttribute,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: rootView,
                                                  attribute: adjustAttribute,
                                                  multiplier: 1,
                                                  constant: 0)
            
            NSLayoutConstraint.activate([leadingConstraint,
                                         tralingConstraint,
                                         offsetConstraint,
                                         heightConstraint])
           
            GTHistoryViewer.shared.alpha = 0.0
            UIView.animate(withDuration: duration,
                           delay: delay,
                           options: .curveEaseIn,
                           animations: {
                GTHistoryViewer.shared.alpha = 1.0
                GTHistoryViewer.shared.scrollToRight()
            }, completion: nil)
        })
    }
    
    static func hide(duration: TimeInterval = 0.5,
                     delay: TimeInterval = 0.0) {
        guard GTHistoryViewer.shared.view.superview != nil else { return }
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: .curveEaseOut,
                       animations: {
                        GTHistoryViewer.shared.alpha = 0.0
                        GTHistoryViewer.shared.scrollToLeft()
        }, completion: { _ in
            GTHistoryViewer.shared.view.removeFromSuperview()
        })
    }
}

class GTHistoryPreviewNode: ASDisplayNode {
    typealias Node = GTHistoryPreviewNode
    
    weak var delegate: GTHistoryViewerProtocol?
    
    lazy var previewImageNode = { () -> ASImageNode in
        let node = ASImageNode()
        node.clipsToBounds = false
        node.isUserInteractionEnabled = true
        node.addTarget(self,
                       action: #selector(self.didTapPreviewImage),
                       forControlEvents: .touchUpInside)
        
        // shadow attribute default setting
        node.shadowColor = self.shadow.shadowColor.cgColor
        node.shadowOffset = self.shadow.shadowOffset
        node.shadowOpacity = self.shadow.shadowOpacity
        node.shadowRadius = self.shadow.shadowRadius
        
        // image node attribute default setting
        node.borderColor = self.preview.frameColor.cgColor
        node.borderWidth = self.preview.previewBorderWidth
        node.cornerRadius = self.preview.previewCornerRadius
        return node
    }()
    
    struct Shadow {
        var shadowColor: UIColor
        var shadowOffset: CGSize
        var shadowOpacity: CGFloat
        var shadowRadius: CGFloat

        init(color: UIColor = .gray,
             offset: CGSize = .init(width: 1.0, height: 1.0),
             opacity: CGFloat = 1.0,
             radius: CGFloat = 1.0) {
            self.shadowColor = color
            self.shadowOffset = offset
            self.shadowOpacity = opacity
            self.shadowRadius = radius
        }
    }
    
    struct Preview {
        var frameColor: UIColor = UIColor.lightGray.withAlphaComponent(0.8)
        var previewCornerRadius: CGFloat = 0.0
        var previewBorderWidth: CGFloat = 0.5
        
        init(frameColor: UIColor = UIColor.lightGray.withAlphaComponent(0.8),
             radius: CGFloat = 0.0,
             borderWidth: CGFloat = 0.5) {
            self.frameColor = frameColor
            self.previewCornerRadius = radius
            self.previewBorderWidth = borderWidth
        }
    }
    
    private let index: Int
    fileprivate var shadow: Shadow
    fileprivate var preview: Preview
    private let screenRatio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
    
    init(_ image: UIImage?,
         index: Int,
         shadowAttribute: Shadow,
         previewAttribute: Preview) {
        self.shadow = shadowAttribute
        self.preview = previewAttribute
        self.index = index
        super.init()
        self.previewImageNode.image = image
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = shadow.shadowColor
    }
    
    @objc func didTapPreviewImage() {
        self.delegate?.didTapPreviewImage(index: self.index)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let ratioLayoutSpec = ASRatioLayoutSpec(ratio: self.screenRatio,
                                                child: self.previewImageNode)
        return ASRelativeLayoutSpec(horizontalPosition: .center,
                                    verticalPosition: .center,
                                    sizingOption: [],
                                    child: ratioLayoutSpec)
    }
}

extension GTHistoryPreviewNode {
    @discardableResult fileprivate func setPreviewImageAttribute(_ block: (inout Node.Preview) -> Void) -> Node {
        block(&self.preview)
        self.previewImageNode.borderColor = self.preview.frameColor.cgColor
        self.previewImageNode.borderWidth = self.preview.previewBorderWidth
        self.previewImageNode.cornerRadius = self.preview.previewCornerRadius
        return self
    }
    
    @discardableResult fileprivate func setPreviewShadowAttribute(_ block: (inout Node.Shadow) -> Void) -> Node {
        block(&self.shadow)
        self.previewImageNode.shadowColor = self.shadow.shadowColor.cgColor
        self.previewImageNode.shadowOffset = self.shadow.shadowOffset
        self.previewImageNode.shadowOpacity = self.shadow.shadowOpacity
        self.previewImageNode.shadowRadius = self.shadow.shadowRadius
        return self
    }
}
