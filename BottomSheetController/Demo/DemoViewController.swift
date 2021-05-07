//
//  DemoViewController.swift
//  BottomSheetController
//
//  Created by 家瑋 on 2021/5/4.
//

import Foundation
import UIKit

protocol DemoViewController where Self: UIViewController {
    static var name: String { get }
    static func show(from parent: UIViewController, in view: UIView?)
}
