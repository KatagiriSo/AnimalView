//
//  ViewController.swift
//  MultiTest
//
//  Created by Katagiri11 on 2016/10/06.
//  Copyright © 2016年 SoKatagiri. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AnimalViewDelegate, UITextFieldDelegate {

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
    
    @IBAction func bluesliderchanged(_ sender: AnyObject) {
        bluecolorText.text = "\(blueslider.value)"
    }
    
    @IBAction func greensliderchanged(_ sender: AnyObject) {
        greenColorText.text = "\(greenslider.value)"
    }

    @IBAction func redsliderchanged(_ sender: AnyObject) {
        redColorText.text = "\(redslider.value)"
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        // アニマルビューのデリゲートを設定してスタートさせてください。
        self.aView.animalDelegate = self
        self.aView.start()
  
    }
    
    
    @IBAction func addButtonPudhed(_ sender: AnyObject) {
        
        guard let rad = radiusTextField.text else {
            return
        }
        
        guard let r_:Int = Int(rad) else {
            return
        }
    
        let r:CGFloat = CGFloat(r_)

        
        let red =  CGFloat(self.redslider.value / 255.0)
        let green = CGFloat(self.greenslider.value / 255.0)
        let blue = CGFloat(self.blueslider.value / 255.0)
        
        let uicolor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        let uid = uidText.text ?? "ADDUID\(count)"
        count = count + 1
        
        // 任意のuid、色、半径を指定してマルを作ります。
        let s = self.aView.makeCircle(uid: uid,
                                      radius: r,
                                      color: uicolor)
        
        // マルをビューに追加します。
        self.aView.addCircle(state: s)
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // アニマルビューのデリゲート
    func touch(view: AnimalView, uid: String) {
        
        print("touch \(uid)")
        let av = UIAlertController(title: "touch", message: uid, preferredStyle: .alert)
        
        // 状態を変えたいときはupdate(mode:.growing)したものを追加してください。そのuidが置き換わります。
        av.addAction(UIAlertAction(title: "growing", style: .default, handler: { (UIAlertAction) in
            if let state = self.aView.getCircleState(uid: uid) {
                let s = state.update(mode:.growing)
                self.aView.addCircle(state: s)
            }
        }))
        
        
        av.addAction(UIAlertAction(title: "floating", style: .default, handler: { (UIAlertAction) in
            if let state = self.aView.getCircleState(uid: uid) {
                let s = state.update(mode:.floating)
                self.aView.addCircle(state: s)
            }
        }))
        
        // 消したい時 deleteAnimal
        av.addAction(UIAlertAction(title: "delete", style: .default, handler: { (UIAlertAction) in
            if let state = self.aView.getCircleState(uid: uid) {
                let s = state.update(mode:.floating)
                self.aView.deleteAnimal(uid: s.uid)
            }
        }))
        
        av.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { (UIAlertAction) in
        }))
        
        self.present(av, animated: true, completion: nil)
        
    }
    
     public func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true
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
