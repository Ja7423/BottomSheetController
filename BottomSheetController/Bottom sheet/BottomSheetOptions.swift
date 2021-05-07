//
//  BottomSheetOptions.swift
//  BottomSheetController
//
//  Created by 家瑋 on 2021/5/6.
//

import Foundation
import UIKit

struct BottomSheetOptions {
    var sheetCornerRadius: CGFloat = 12.0
    
    var sheetColor: UIColor = .black
    var pullBarColor: UIColor = .lightGray
    
    var animationDuration: TimeInterval = 0.3
    var springVelocity: CGFloat = 0.8
    var springDamping: CGFloat = 0.7
    
    static let defaultOptions = BottomSheetOptions()
}
