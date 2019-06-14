//
//  ViewController.swift
//  Semaphore
//
//  Created by 王叶庆 on 2019/4/25.
//  Copyright © 2019 王叶庆. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global()
        for i in 0..<100 {
            queue.async {
                print("add \(i)")
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

}

