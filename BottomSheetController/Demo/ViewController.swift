//
//  ViewController.swift
//  BottomSheetController
//
//  Created by 家瑋 on 2021/4/17.
//

import UIKit

class ViewController: UIViewController {
    
    enum DisplayMode: String {
        case inView
        case present
        
        static let allValues: [DisplayMode.RawValue] = [DisplayMode.inView.rawValue,
                                                        DisplayMode.present.rawValue]
    }
    
    var currentMode: DisplayMode = .inView
    
    lazy var segment: UISegmentedControl = {
        let segment = UISegmentedControl(items: DisplayMode.allValues)
        
        let normalColor: UIColor
        if #available(iOS 13.0, *) {
            segment.backgroundColor = UIColor(red: 184.0/255.0,
                                              green: 249.9/255.0,
                                              blue: 255.0/255.0, alpha: 1.0)
            segment.selectedSegmentTintColor = .white
            normalColor = .white
        } else {
            segment.backgroundColor = .white
            segment.tintColor = UIColor(red: 184.0/255.0,
                                        green: 249.9/255.0,
                                        blue: 255.0/255.0, alpha: 1.0)
            normalColor = UIColor(white: 0.8, alpha: 1.0)
        }
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: normalColor], for: .normal)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(selectedSegment(_:)), for: .valueChanged)
        return segment
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 10.0
        return stackView
    }()
    
    var demoControllers: [DemoViewController.Type] = [
        TableViewController.self,
        IntrinsicViewController.self,
        TextViewViewController.self,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        segment.selectedSegmentIndex = 0
        view.addSubview(segment)
        NSLayoutConstraint.activate([
            segment.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            segment.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -20),
        ])
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            stackView.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 20),
        ])
        
        addButtons()
    }
    
    func addButtons() {
        for (index, vc) in demoControllers.enumerated() {
            let name = vc.name
            let button = UIButton(type: .custom)
            button.setTitle(name, for: .normal)
            button.setTitleColor(UIColor(red: 100.0/255.0,
                                         green: 249.9/255.0,
                                         blue: 255.0/255.0, alpha: 1.0),
                                 for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: .regular)
            button.addTarget(self, action: #selector(showBottomSheet(_:)), for: .touchUpInside)
            button.tag = index
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc func showBottomSheet(_ sender: UIButton) {
        let vc = demoControllers[sender.tag]
        open(vc, from: self)
    }
    
    func open(_ demoVC: DemoViewController.Type, from parent: UIViewController) {
        let view: UIView? = currentMode == .inView ? parent.view : nil
        demoVC.show(from: parent, in: view)
    }
    
    @objc func selectedSegment(_ sender: UISegmentedControl) {
        currentMode = sender.selectedSegmentIndex == 0 ? .inView : .present
    }
}

