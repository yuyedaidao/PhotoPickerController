//
//  PhtotoModel.swift
//  Example
//
//  Created by 张晓鑫 on 2019/7/1.
//  Copyright © 2019 王叶庆. All rights reserved.
//

import Photos

//enum AssetMediaType {
//    case unKnow
//    case image
//    case gif
//    case video
//    case audio
//}

class PhotoModel {
    var asset: PHAsset
//    var type: AssetMediaType?
    var selected = false
    
    init(asset: PHAsset) {
        self.asset = asset
    }
}
