//
//  TextViewViewController.swift
//  BottomSheetController
//
//  Created by 家瑋 on 2021/5/6.
//

import UIKit

class TextViewViewController: UIViewController {

    private lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.textColor = .black
        textView.backgroundColor = .lightGray
        textView.layer.borderColor = UIColor.red.cgColor
        textView.layer.borderWidth = 2.0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = true
        return textView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.textColor = .white
        button.addTarget(self, action: #selector(done(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    deinit {
        print("TextViewViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            doneButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
        ])
        
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 3),
            textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
        ])
        
        self.bottomSheet?.handlContentScrollView(textView)
//        self.bottomSheet?.allowPullPastMax = false
    }
    
    @objc private func done(_ sender: UIButton) {
        textView.resignFirstResponder()
//        self.bottomSheet?.dismiss(completion: nil)
    }
}

extension TextViewViewController: DemoViewController {
    static var name: String {
        return "TextView"
    }
    
    static func show(from parent: UIViewController, in view: UIView?) {
        let bottomSheetController = BottomSheetController(TextViewViewController(),
                                                          sheetSizes: [.fixed(300)])
        if let view = view {
            bottomSheetController.show(in: parent, on: view)
        }
        else {
            parent.present(bottomSheetController, animated: true, completion: nil)
        }
    }
}
