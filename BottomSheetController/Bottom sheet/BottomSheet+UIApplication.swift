//
//  BottomSheet+UIApplication.swift
//  BottomSheetController
//
//  Created by 家瑋 on 2021/5/4.
//

import Foundation
import UIKit

extension UIApplication {
    var safeAreaInsets: UIEdgeInsets {
        return self.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero
    }
}
