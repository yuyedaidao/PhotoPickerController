//
//  ViewController.swift
//  PhotoPickerController
//
//  Created by 张晓鑫 on 2017/6/13.
//  Copyright © 2017年 张晓鑫. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if let vc = UIStoryboard(name: "ImagePicker", bundle:Bundle.main).instantiateViewController(withIdentifier: "PhotoPickerController") as? PhotoPickerController {
//            vc.maxSelected = Int.max
//            let nav = UINavigationController(rootViewController: vc)
//            self.present(nav, animated: true, completion: nil)
//        }
        let vc = PhotoPickerController.init()
        vc.view.frame = self.view.frame
        vc.maxSelected = Int.max
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

