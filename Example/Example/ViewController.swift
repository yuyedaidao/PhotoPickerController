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
    var selectedIdentify = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    @IBAction func imagePicker(_ sender: UIButton) {
        let picker = PhotoPickerController(type:PHAssetMediaType.image)
        picker.selectedIdentify = selectedIdentify
        picker.completeHandler = { [weak self] assets in
            guard let self = self else { return }
            for asset in assets {
                self.selectedIdentify.append(asset.localIdentifier)
            }
            
        }
        present(UINavigationController(rootViewController: picker), animated: true, completion: nil)
        
    }
    
}

