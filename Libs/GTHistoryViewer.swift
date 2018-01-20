import AsyncDisplayKit

class GTHistoryViewer: ASScrollNode {
    typealias PreviewNode = GTHistoryPreviewNode
    static let shared: GTHistoryViewer = GTHistoryViewer()
    private var historyStack: [PreviewNode] = []
    private var spacing: CGFloat = 10.0
    private var stackAreaInsets: UIEdgeInsets = .init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    init(customShadowAttribute: PreviewNode.Shadow? = nil,
         customPreviewAttribute: PreviewNode.Preview? = nil) {
        super.init()
        self.scrollableDirections = [.left, .right]
        self.automaticallyManagesContentSize = true
        self.automaticallyManagesSubnodes = true
    }
    
    func willMove(_ presentViewController: UIViewController, parent: UIViewController?) {
        if parent != nil {
            // Push new viewcontroller on navigation controller
            let image = captureScreen(presentViewController)
            let previewNode = PreviewNode(image: image)
            previewNode.style.spacingBefore = self.spacing
            historyStack.append(previewNode)
            self.setNeedsLayout()
            
            let rightOffset = CGPoint(x: self.view.contentSize.width - self.view.bounds.size.width,
                                      y: 0.0)
            self.view.setContentOffset(rightOffset, animated: true)
        } else {
            // Pop stack on navigation controller
            _ = self.historyStack.popLast()
            self.setNeedsLayout()
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

extension GTHistoryViewer {
    static func show(_ previewHeight: CGFloat = 200.0) {
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
            
            let bottomConstraint = NSLayoutConstraint(item: node.view,
                                                       attribute: NSLayoutAttribute.bottom,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: rootView,
                                                       attribute: NSLayoutAttribute.bottom,
                                                       multiplier: 1,
                                                       constant: 0)
            
            let heightConstraint = NSLayoutConstraint(item: node.view,
                                                      attribute: NSLayoutAttribute.height,
                                                      relatedBy: NSLayoutRelation.equal,
                                                      toItem: nil,
                                                      attribute: NSLayoutAttribute.height,
                                                      multiplier: 1,
                                                      constant: previewHeight)

            NSLayoutConstraint.activate([leadingConstraint,
                                         tralingConstraint,
                                         bottomConstraint,
                                         heightConstraint])
           
            GTHistoryViewer.shared.alpha = 0.0
            UIView.animate(withDuration: 0.5, animations: {
                GTHistoryViewer.shared.alpha = 1.0
            }, completion: nil)

        })
    }
    
    static func hide() {
        guard GTHistoryViewer.shared.view.superview != nil else { return }
        UIView.animate(withDuration: 0.5, animations: {
            GTHistoryViewer.shared.alpha = 0.0
        }, completion: { _ in
            GTHistoryViewer.shared.view.removeFromSuperview()
        })
    }
}

class GTHistoryPreviewNode: ASDisplayNode {
    typealias Node = GTHistoryPreviewNode
    lazy var previewImageNode = { () -> ASImageNode in
        let node = ASImageNode()
        node.clipsToBounds = false

        // shadow attribute default setting
        node.shadowColor = self.shadow.shadowColor.cgColor
        node.shadowOffset = self.shadow.shadowOffset
        node.shadowOpacity = self.shadow.shadowOpacity
        node.shadowRadius = self.shadow.shadowRadius
        
        // image node attribute default setting
        node.borderColor = self.preview.defaultFrameColor.cgColor
        node.borderWidth = self.preview.previewBorderWidth
        node.cornerRadius = self.preview.previewCornerRadius
        return node
    }()
    
    struct Shadow {
        var shadowColor: UIColor = .gray
        var shadowOffset: CGSize = .init(width: 0.0, height: 1.0)
        var shadowOpacity: CGFloat = 1.0
        var shadowRadius: CGFloat = 1.0
    }
    
    struct Preview {
        var defaultFrameColor: UIColor = UIColor.lightGray
        var selectedFrameColor: UIColor = UIColor.red
        var previewCornerRadius: CGFloat = 0.0
        var previewBorderWidth: CGFloat = 1.0
    }
    
    let shadow: Shadow
    let preview: Preview
    let screenRatio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
    
    init(image: UIImage?, shadowAttribute: Shadow = Shadow(), previewAttribute: Preview = Preview()) {
        self.shadow = shadowAttribute
        self.preview = previewAttribute
        super.init()
        self.previewImageNode.image = image
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = shadow.shadowColor
    }
    
    func updateStatus(didSelected: Bool) {
        self.previewImageNode.borderColor = didSelected ?
            preview.selectedFrameColor.cgColor:
            preview.defaultFrameColor.cgColor
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
    @discardableResult func setPreviewImageAttribute(_ block: (Node.Preview) -> Void) -> Node {
        block(self.preview)
        self.previewImageNode.shadowColor = self.shadow.shadowColor.cgColor
        self.previewImageNode.shadowOffset = self.shadow.shadowOffset
        self.previewImageNode.shadowOpacity = self.shadow.shadowOpacity
        self.previewImageNode.shadowRadius = self.shadow.shadowRadius
        return self
    }
    
    @discardableResult func setPreviewShadow(_ block: (Node.Shadow) -> Void) -> Node {
        block(self.shadow)
        self.previewImageNode.shadowColor = self.shadow.shadowColor.cgColor
        self.previewImageNode.shadowOffset = self.shadow.shadowOffset
        self.previewImageNode.shadowOpacity = self.shadow.shadowOpacity
        self.previewImageNode.shadowRadius = self.shadow.shadowRadius
        return self
    }
}
