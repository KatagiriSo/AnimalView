//
//  AnimalView.swift
//
//  Created by 片桐奏羽 on 2016/02/18.
//  Copyright (c) 2016年 SoKatagiri. 
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

import UIKit
import QuartzCore

func randumAddPoint(_ point:CGPoint) -> CGPoint {
    
    var x = point.x
    var y = point.y
    switch (arc4random() % 4) {
    case 0: x += 1
    case 1: y += 1
    case 2: x -= 1
    case 3: y -= 1
    default:
        break
    }
    
    return CGPoint(x:x, y:y);
}

typealias Vec = CGPoint
typealias dVec = CGPoint
typealias State = (Vec, dVec)

func initialState(_ n:NSInteger, point:CGPoint)->[State] {
    
    var l:[State] = []
    for _ in 0 ... n {
        let state:State = State(point, dVec(x:0,y:0))
        l.append(state)
    }
    return l
}


class AnimalView: UIView {
    
    //var context:CGContext?
    var list:[State]? = []
    
    var context:CGContext? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        start()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
            start()
    }


    
    func drawCircle(_ rect:CGRect) {
        
        context?.strokeEllipse(in: rect)
        context?.strokePath()
    }
    
    func drawCircle(_ point:CGPoint, radius:CGFloat) {
        
        let r = CGRect(x: point.x - radius, y: point.y - radius, width: radius*2, height: radius * 2)
        drawCircle(r)
    }
    
    func drawCirclePoint(_ point:CGPoint) {
        
        let r = CGFloat(arc4random() % 10+10)
        drawCircle(point, radius: r)
    }
    
    func update(_ list:[State]) -> [State] {

        let width = self.frame.width
        let height = self.frame.height
        
        return list.map { (state:State) -> State in
            var r = state.0
            var v = state.1
            v = randumAddPoint(v)
            r.x = r.x + v.x / 5
            r.y = r.y + v.y / 5
            if (r.y > height) {r.y = height;v.y = 0} else if (r.y <= 5)    {r.y = 5; v.y = 0}
            if (r.x <= 5)     {r.x = 5; v.x = 0}     else if (r.x > width) {r.x = width;v.x = 0}
            return (r,v)
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        context?.setLineWidth(3)
        context?.setStrokeColor(red: 0, green: 0, blue: 1, alpha: 1)
        context?.setLineCap(CGLineCap.round)
        
        for p in list! { drawCirclePoint(p.0) }
    }
    
    func start() {
        
        self.list  = initialState(100, point:self.center)
        Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(AnimalView.timeFired(_:)), userInfo: nil, repeats: true)
    }
    
    func timeFired(_ timer:Timer) {
        
        self.list =  update(self.list!)
        self.setNeedsLayout()
        self.setNeedsDisplay()
    }
}
