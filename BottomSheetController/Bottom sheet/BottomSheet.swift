//
//  BottomSheet.swift
//  BottomSheetController
//
//  Created by 家瑋 on 2021/4/17.
//

import UIKit

enum BottomSheetSize {
    case intrinsic
    case fixed(CGFloat)
    case percent(CGFloat)
    case fullscreen
}

class BottomSheetController: UIViewController {
    
    let containerViewController: SheetContainerViewController
    let options: BottomSheetOptions
    
    // MARK: - Public setting
    public var sheetSizes: [BottomSheetSize] {
        didSet {
            sortSize()
        }
    }
    
    public var touchDismiss: Bool = true {
        didSet {
            view.isUserInteractionEnabled = touchDismiss
        }
    }
    
    public var pullDismiss: Bool = true
    public var allowPullPastMax: Bool = true
    
    public var sheetColor: UIColor {
        set { containerViewController.sheetColor = newValue }
        get { containerViewController.sheetColor }
    }
    
    // MARK: -
    
    private var orderedSheetSizes: [BottomSheetSize] = []
    private var currentSize: BottomSheetSize = .intrinsic
    private var heightConstraint: NSLayoutConstraint?
    private var lastPoint: CGPoint = .zero
    
    private var keyboardHeight: CGFloat = 0
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(handlePanGesture(_:)))
        gesture.delegate = self
        return gesture
    }()
    
    private weak var scrollView: UIScrollView?
    
    
    deinit {
        print("BottomSheetController deinit")
        removeKeyboardObserver()
    }
    
    init(_ contentViewController: UIViewController, sheetSizes: [BottomSheetSize] = [.intrinsic], options: BottomSheetOptions = .defaultOptions) {
        self.containerViewController = SheetContainerViewController(contentViewController,
                                                                    options: options)
        self.sheetSizes = sheetSizes
        self.options = options
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = touchDismiss
        addKeyboardObserver()
    }
    
    private func setup() {
        sortSize()
        currentSize = orderedSheetSizes.first ?? currentSize
        
        addChild(containerViewController)
        view.addSubview(containerViewController.view)
        containerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        containerViewController.didMove(toParent: self)
        
        let height = self.height(for: currentSize)
        let heightConstraint = containerViewController.view.heightAnchor.constraint(equalToConstant: height)
        self.heightConstraint = heightConstraint
        NSLayoutConstraint.activate([
            containerViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            containerViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            containerViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            heightConstraint,
        ])
        
        addPanGesture()
    }
    
    // MARK: - Public
    public func show(in parent: UIViewController,
                     on view: UIView,
                     completion: ((Bool) -> Void)? = nil) {
        willMove(toParent: parent)
        parent.addChild(self)
        view.addSubview(self.view)
        didMove(toParent: parent)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: view.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        animationIn(duration: options.animationDuration, completion: completion)
    }
    
    public func dismiss(completion: ((Bool) -> Void)? = nil) {
        if presentingViewController != nil {
            dismiss(animated: true, completion: {
                completion?(true)
            })
            return
        }
        
        animationOut(duration: options.animationDuration, completion: completion)
    }
    
    // MARK: -
    private func animationIn(duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        self.view.layoutIfNeeded()
        let height = containerViewController.view.frame.size.height
        
        containerViewController.view.transform = CGAffineTransform(translationX: 0, y: height)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
                        guard let self = self else { return }
                        self.containerViewController.view.transform = CGAffineTransform.identity
                       }, completion: { (completed) in
                        completion?(completed)
                       })
    }
    
    private func animationOut(duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        let height = containerViewController.view.frame.size.height
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
                        guard let self = self else { return }
                        self.containerViewController.view.transform = CGAffineTransform(translationX: 0, y: height)
                       }, completion: { [weak self] (completed) in
                        guard let self = self else { return }
                        self.view.removeFromSuperview()
                        self.removeFromParent()
                        completion?(completed)
                       })
    }
    
    // MARK: - Size
    private func sortSize() {
        let sortedSize = sheetSizes.map({ return ($0, height(for: $0)) }).sorted(by: { $0.1 < $1.1 })
        orderedSheetSizes = sortedSize.map({ $0.0 })
    }
    
    private func height(for size: BottomSheetSize?) -> CGFloat {
        guard let size = size else { return 0 }
        let fullHeight = self.view.bounds.size.height - self.view.safeAreaInsets.top
        let contentHeight: CGFloat
        
        switch size {
        case .intrinsic:
            contentHeight = self.containerViewController.preferredContentHeight + keyboardHeight
        case .fixed(let height):
            contentHeight = height + keyboardHeight
        case .percent(let percent):
            contentHeight = self.view.bounds.height * percent + keyboardHeight
        case .fullscreen:
            contentHeight = fullHeight
        }
        
        print("-------------------------------")
        print("bottom safeArea: \(UIApplication.shared.safeAreaInsets.bottom)")
        print("contentHeight: \(contentHeight)")
        print("keyboardHeight: \(keyboardHeight)")
        print("-------------------------------")
        return min(contentHeight, fullHeight)
    }
    
    private func sheetWidth() -> CGFloat {
        return self.view.bounds.width > 0 ? self.view.bounds.width : UIScreen.main.bounds.width
    }
    
    private func reachMaxHeight() -> Bool {
        let maxHeight = self.allowPullPastMax ? height(for: .fullscreen) : getMaxHeight()
        return containerViewController.view.bounds.height >= maxHeight
    }
    
    private func getMaxHeight() -> CGFloat {
        let maxHeight = height(for: orderedSheetSizes.last)
        return maxHeight
    }
    
    private func preferredSheetSize(_ height: CGFloat) -> BottomSheetSize? {
        var leftSize: BottomSheetSize? = orderedSheetSizes.first
        var rightSize: BottomSheetSize? = orderedSheetSizes.last
        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0
        
        for size in orderedSheetSizes {
            let h = self.height(for: size)
            if h <= height {
                leftSize = size
            }
            else {
                rightSize = size
                break
            }
        }
        
        leftHeight = self.height(for: leftSize)
        rightHeight = self.height(for: rightSize)
        return (height - leftHeight) < (rightHeight - height) ? leftSize : rightSize
    }
    
    private func resize(_ size: BottomSheetSize, duration: TimeInterval, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: options.springDamping,
                       initialSpringVelocity: options.springVelocity,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        guard let self = self else { return }
                        self.heightConstraint?.constant = self.height(for: size)
                        self.view.layoutIfNeeded()
        }, completion: { [weak self] (completed) in
            guard let self = self else { return }
            self.currentSize = size
            completion?()
        })
    }
}

// MARK: - Gesture
extension BottomSheetController: UIGestureRecognizerDelegate {
    
    public func handlContentScrollView(_ scrollView: UIScrollView) {
        scrollView.panGestureRecognizer.require(toFail: panGesture)
        self.scrollView = scrollView
    }
    
    private func addPanGesture() {
        containerViewController.view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: containerViewController.view)
        let currentHeight = containerViewController.view.bounds.height
        
        switch gesture.state {
        case .began:
            lastPoint = translation
            break
        case .changed:
            let heightOffset = lastPoint.y - translation.y
            var newHeight = max(0, currentHeight + heightOffset)
            let maxHeight = self.allowPullPastMax ? height(for: .fullscreen) : getMaxHeight()
            newHeight = min(newHeight, maxHeight)
            heightConstraint?.constant = newHeight
            
            lastPoint = translation
        case .ended:
            let velocity = 0.3 * gesture.velocity(in: containerViewController.view).y
            let newHeight = (heightConstraint?.constant ?? 0) - velocity
            print("velocity: \(velocity), newHeight: \(newHeight)")
            guard let preferredSize = preferredSheetSize(newHeight),
                  (newHeight > 0 || !self.pullDismiss) else {
                dismiss()
                return
            }
            
            let animationDuration = abs(Double(velocity) * 0.0002) + options.animationDuration
            resize(preferredSize, duration: animationDuration, completion: nil)
            lastPoint = .zero
        case .possible: break
        case .cancelled, .failed:
            resize(self.currentSize, duration: options.animationDuration, completion: nil)
            lastPoint = .zero
        @unknown default: break
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pangesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = pangesture.velocity(in: containerViewController.view)
        
        // 橫向拖動
        if abs(velocity.x) > abs(velocity.y) { return false }
        
        if velocity.y < 0 {
            // 手指往上
            return !reachMaxHeight()
        } else {
            // 手指往下
            if let scrollView = scrollView {
                return scrollView.contentOffset.y <= -scrollView.contentInset.top
            }
            
            return true
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let touchView = touch.view else { return }
        guard touchView === view else { return }
        if touchDismiss { dismiss() }
    }
}

// MARK: - Keyboard
extension BottomSheetController {
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)),
                                               name: BottomSheetController.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: BottomSheetController.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardDidShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[BottomSheetController.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = frameValue.cgRectValue
        keyboardHeight = keyboardFrame.height
        adjustKeyboard()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
        adjustKeyboard()
    }
    
    private func adjustKeyboard() {
        containerViewController.adjustKeyboard(keyboardHeight)
        resize(self.currentSize, duration: options.animationDuration, completion: nil)
    }
}
