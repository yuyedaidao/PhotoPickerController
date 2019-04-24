//
//  PhotoPickerControllerImage.swift
//  PhotoPickerController
//
//  Created by 王叶庆 on 2019/4/24.
//

import Foundation
class PhotoPickerControllerImage: UIImage {
}

extension UIImage {
    static let bundle = Bundle(for: PhotoPickerControllerImage.classForCoder())
    static func named(_ name: String) -> UIImage? {
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
