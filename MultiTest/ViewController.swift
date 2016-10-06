//
//  ViewController.swift
//  MultiTest
//
//  Created by Katagiri11 on 2016/10/06.
//  Copyright © 2016年 SoKatagiri. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AnimalViewDelegate {

    @IBOutlet weak var aView: AnimalView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let c1 = self.aView.makeCircle("ab", radius: 30, color: UIColor.blueColor())
        let c2 = self.aView.makeCircle("fdd", radius: 10, color: UIColor.redColor())
        let c3 = self.aView.makeCircle("sdsdf", radius: 20, color: UIColor.greenColor())
        
        self.aView.addCircle(c1)
        self.aView.addCircle(c2)
        self.aView.addCircle(c3)
        self.aView.animalDelegate = self
        self.aView.start()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touch(view: AnimalView, uid: String) {
        print("touch \(uid)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
