//
//  TestViewController.swift
//  iAlert
//
//  Created by Assaf Tayouri on 14/08/2018.
//  Copyright © 2018 Lior Cohen. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    @IBOutlet var container: UIView!
    @IBOutlet weak var c: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = c.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        c.addSubview(visualEffectView)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
