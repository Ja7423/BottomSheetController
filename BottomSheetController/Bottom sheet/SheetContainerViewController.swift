//
//  SheetContainerViewController.swift
//  BottomSheetController
//
//  Created by 家瑋 on 2021/5/4.
//

import UIKit

class SheetContainerViewController: UIViewController {

    let contentViewController: UIViewController
    
    public var sheetColor: UIColor {
        set { _sheetColor = newValue }
        get { _sheetColor }
    }
    
    public var pullBarColor: UIColor {
        set { _pullBarColor = newValue }
        get { _pullBarColor }
    }
    
    private(set) var preferredContentHeight: CGFloat = 0
    
    // MARK: -
    private var _sheetColor: UIColor {
        didSet {
            container.backgroundColor = _sheetColor
        }
    }
    
    private var _pullBarColor: UIColor {
        didSet {
            pullBar.backgroundColor = _pullBarColor
        }
    }
    
    private let cornerRadius: CGFloat
    
    private var bottomConstraint: NSLayoutConstraint?
    
    private lazy var contentView: UIView = {
        let contentView = UIView(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private lazy var cornerView: UIView = {
        let cornerView = UIView(frame: .zero)
        cornerView.translatesAutoresizingMaskIntoConstraints = false
        return cornerView
    }()
    
    private lazy var container: UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var pullBar: UIView = {
        let pullBar = UIView(frame: .zero)
        pullBar.translatesAutoresizingMaskIntoConstraints = false
        return pullBar
    }()
    
    
    deinit {
        print("SheetContainerViewController deinit")
    }
    
    init(_ contentViewController: UIViewController, options: BottomSheetOptions) {
        self.contentViewController = contentViewController
        
        self._pullBarColor = options.pullBarColor
        self._sheetColor = options.sheetColor
        self.cornerRadius = options.sheetCornerRadius
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        addContentView()
        addCornerMask()
        addContentContainer()
        addPullBar()
        addContent()
        updatePreferredContentHeight()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    func adjustKeyboard(_ keyboardHeight: CGFloat) {
        bottomConstraint?.constant = -keyboardHeight
    }
    
    // MARK: -
    private func addContentView() {
        contentView.backgroundColor = .clear
        view.addSubview(contentView)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.view.topAnchor),
            contentView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            bottomConstraint
        ])
        
        self.bottomConstraint = bottomConstraint
    }
    
    private func addCornerMask() {
        cornerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cornerView.layer.masksToBounds = true
        cornerView.layer.cornerRadius = cornerRadius
        cornerView.backgroundColor = .clear
        contentView.addSubview(cornerView)
        NSLayoutConstraint.activate([
            cornerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cornerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            cornerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            cornerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func addContentContainer() {
        container.backgroundColor = _sheetColor
        cornerView.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: cornerView.topAnchor),
            container.leftAnchor.constraint(equalTo: cornerView.leftAnchor),
            container.rightAnchor.constraint(equalTo: cornerView.rightAnchor),
            container.bottomAnchor.constraint(equalTo: cornerView.bottomAnchor)
        ])
    }
    
    private func addPullBar() {
        let height: CGFloat = 8.0
        pullBar.backgroundColor = _pullBarColor
        pullBar.layer.cornerRadius = height/2
        container.addSubview(pullBar)
        NSLayoutConstraint.activate([
            pullBar.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            pullBar.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            pullBar.heightAnchor.constraint(equalToConstant: height),
            pullBar.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.15)
        ])
    }
    
    private func addContent() {
        addChild(contentViewController)
        container.addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: pullBar.bottomAnchor, constant: 8),
            contentViewController.view.leftAnchor.constraint(equalTo: container.leftAnchor),
            contentViewController.view.rightAnchor.constraint(equalTo: container.rightAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -UIApplication.shared.safeAreaInsets.bottom),
        ])
    }
    
    private func updatePreferredContentHeight() {
        var fittingSize = UIView.layoutFittingCompressedSize;
        fittingSize.width = self.view.bounds.width > 0 ? self.view.bounds.width : UIScreen.main.bounds.width
        
        UIView.performWithoutAnimation {
            self.view.layoutSubviews()
        }
        
        preferredContentHeight = self.view.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow).height
    }
}

