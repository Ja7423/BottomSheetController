//
//  IntrinsicViewController.swift
//  BottomSheetController
//
//  Created by 家瑋 on 2021/5/4.
//

import UIKit

class IntrinsicViewController: UIViewController {
    
    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 18.0, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    deinit {
        print("IntrinsicViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)
        ])
        
        label.text = "Intrinsic Demo"
    }
}

extension IntrinsicViewController: DemoViewController {
    static var name: String {
        return "Intrinsic"
    }
    
    static func show(from parent: UIViewController, in view: UIView?) {
        let options = BottomSheetOptions(sheetColor: .lightGray, pullBarColor: .black)
        let bottomSheetController = BottomSheetController(IntrinsicViewController(), options: options)
        if let view = view {
            bottomSheetController.show(in: parent, on: view)
        }
        else {
            parent.present(bottomSheetController, animated: true, completion: nil)
        }
    }
}
