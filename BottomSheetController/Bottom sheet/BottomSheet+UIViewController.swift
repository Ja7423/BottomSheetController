//
//  BottomSheet+UIViewController.swift
//  BottomSheetController
//
//  Created by 家瑋 on 2021/5/5.
//

import Foundation
import UIKit

extension UIViewController {
    var bottomSheet: BottomSheetController? {
        
        var target = self
        while let parent = target.parent {
            target = parent
            if target is BottomSheetController {
                break
            }
        }
        return target as? BottomSheetController
    }
}
