//
//  TableViewController.swift
//  BottomSheetController
//
//  Created by 家瑋 on 2021/4/18.
//

import UIKit

class TableViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    deinit {
        print("TableViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addTableView()
        
        self.bottomSheet?.handlContentScrollView(tableView)
    }
    
    func addTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

extension TableViewController: DemoViewController {
    static var name: String {
        return "TableView"
    }
    
    static func show(from parent: UIViewController, in view: UIView?) {
        let bottomSheetController = BottomSheetController(TableViewController(),
                                                          sheetSizes: [.percent(0.25),
                                                                       .percent(0.5),
                                                                       .fullscreen])
        if let view = view {
            bottomSheetController.show(in: parent, on: view)
        }
        else {
            parent.present(bottomSheetController, animated: true, completion: nil)
        }
    }
}

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "row: \(indexPath.row)"
        return cell
    }
}

extension TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
