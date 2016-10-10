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
    @IBOutlet weak var radiusTextField: UITextField!
    
    var count = 0 {
        didSet {
            uidText.text = "ADDUID\(count)"
        }
    }
    
    
    @IBOutlet weak var uidText: UITextField!

    
    
    @IBOutlet weak var blueslider: UISlider!
    @IBOutlet weak var greenslider: UISlider!
    @IBOutlet weak var redslider: UISlider!
    
    @IBOutlet weak var bluecolorText: UILabel!
    @IBOutlet weak var greenColorText: UILabel!
    @IBOutlet weak var redColorText: UILabel!
    
    @IBAction func bluesliderchanged(sender: AnyObject) {
        bluecolorText.text = "\(blueslider.value)"
    }
    
    @IBAction func greensliderchanged(sender: AnyObject) {
        greenColorText.text = "\(greenslider.value)"
    }
    @IBAction func redsliderchanged(sender: AnyObject) {
        redColorText.text = "\(redslider.value)"
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()


        // Do any additional setup after loading the view.

        
//        let c1 = self.aView.makeCircle("ab", radius: 30, color: UIColor.blueColor())
//        let c2 = self.aView.makeCircle("fdd", radius: 10, color: UIColor.redColor())
//        let c3 = self.aView.makeCircle("sdsdf", radius: 20, color: UIColor.greenColor())
//        
//        self.aView.addCircle(c1)
//        self.aView.addCircle(c2)
//        self.aView.addCircle(c3)
        self.aView.animalDelegate = self
        self.aView.start()
        
        
    }
    
    @IBAction func addButtonPudhed(sender: AnyObject) {
        
        guard let rad = radiusTextField.text else {
            return
        }
        
        guard let r_:Int = Int(rad) else {
            return
        }
    
        guard let r:CGFloat = CGFloat(r_) else {
            return
        }
    
        

        
        let red =  CGFloat(self.redslider.value / 255.0)
        let green = CGFloat(self.greenslider.value / 255.0)
        let blue = CGFloat(self.blueslider.value / 255.0)
        
        let uicolor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        let uid = uidText.text ?? "ADDUID\(count)"
        count = count + 1
        
        let s = self.aView.makeCircle(uid,
                                      radius: r, color: uicolor)
        self.aView.addCircle(s)
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touch(view: AnimalView, uid: String) {
        print("touch \(uid)")
        let av = UIAlertController(title: "touch", message: uid, preferredStyle: .Alert)
        av.addAction(UIAlertAction(title: "growing", style: .Default, handler: { (UIAlertAction) in
            if let state = self.aView.getCircleState(uid) {
                let s = state.update(mode:.growing)
                self.aView.addCircle(s)
            }
        }))
        av.addAction(UIAlertAction(title: "floating", style: .Default, handler: { (UIAlertAction) in
            if let state = self.aView.getCircleState(uid) {
                let s = state.update(mode:.floating)
                self.aView.addCircle(s)
            }
        }))
        
        av.addAction(UIAlertAction(title: "delete", style: .Default, handler: { (UIAlertAction) in
            if let state = self.aView.getCircleState(uid) {
                let s = state.update(mode:.floating)
                self.aView.deleteAnimal(s.uid)
            }
        }))
        
        av.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: { (UIAlertAction) in
        }))
        
        self.presentViewController(av, animated: true, completion: nil)
        
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
