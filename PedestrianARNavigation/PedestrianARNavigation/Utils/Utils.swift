//
//  Utils.swift
//  FinishPlacemarkHelper
//
//  Created by Dmitry Trimonov on 16/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension UIImage {
    class func image(from view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        view.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

public extension NSAttributedString {

    public func boundingRect(size: CGSize) -> CGRect {
        let rect = self.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        return rect.integral
    }

    public func boundingRect(width: CGFloat) -> CGRect {
        return boundingRect(size: CGSize(width: width, height: .infinity))
    }

    public func boundingSize(width: CGFloat) -> CGSize {
        return boundingRect(width: width).size
    }

}
