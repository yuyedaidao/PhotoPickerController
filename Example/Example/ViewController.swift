//
//  ViewController.swift
//  Example
//
//  Created by 王叶庆 on 2019/4/24.
//  Copyright © 2019 王叶庆. All rights reserved.
//

import UIKit
import PhotoPickerController
import Photos
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let picker = PhotoPickerController(type:PHAssetMediaType.video)
        present(UINavigationController(rootViewController: picker), animated: true, completion: nil)
    }

}

