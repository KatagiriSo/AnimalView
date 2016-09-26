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
typealias Radius = CGFloat
typealias dRadius = CGFloat
typealias State = (Vec, dVec, Radius, dRadius)
typealias LineState = (origin:Vec, speed:dVec, direction:Vec, length:CGFloat, life:CGFloat)



class AnimalView: UIView {
    
    var touchmode:Bool = false
    var touchPoint:CGPoint = CGPoint.zero
    
    //var context:CGContext?
    var list:[LineState]? = []
    
    var context:CGContext? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        start()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        start()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchmode = true
        if let touch:UITouch = touches.first {
            let point = touch.location(in: self)
            touchPoint = point
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch:UITouch = touches.first {
            let point = touch.location(in: self)
            touchPoint = point
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchmode = false
    }
    
    
    func drawCircle(_ rect:CGRect) {
        
        context?.strokeEllipse(in: rect)
        context?.strokePath()
    }
    
    func drawCircle(_ point:CGPoint, radius:CGFloat) {
        
        let r = CGRect(x: point.x - radius, y: point.y - radius, width: radius*2, height: radius * 2)
        drawCircle(r)
    }
    
    func drawCirclePoint(_ point:CGPoint, r:Radius) {
        
        drawCircle(point, radius: r)
    }
    
    func drawLine(point:CGPoint, direction:CGPoint, length:CGFloat) {
        
        let nx = direction.x
        let ny = direction.y
        let n2 = nx * nx + ny * ny
        let kx = nx * sqrt(n2)
        let ky = ny * sqrt(n2)
        let lx = length * kx
        let ly = length * ky
        let fromX = point.x - lx/2
        let fromY = point.y - ly/2
        let toX = point.x + lx/2
        let toY = point.y + ly/2
        let fromP = CGPoint(x:fromX, y:fromY)
        let toP = CGPoint(x:toX, y:toY)
        
        context?.move(to: fromP)
        context?.addLine(to: toP)
        context?.strokePath()
        
    }
    
    func update(_ list:[LineState]) -> [LineState] {
        
        let width = self.frame.width
        let height = self.frame.height
        
        return list.map { (state:LineState) -> LineState in
            
            let l = state.length
            let life = state.life
            var d = state.direction
    
            let angle = CGFloat(M_PI_4 * (1/90) * 60)
            d.x = cos(angle) * d.x - sin(angle) * d.y
            d.y = sin(angle) * d.x + cos(angle) * d.y
            let dd = sqrt(d.x*d.x + d.y*d.y)
            d.x = d.x/dd
            d.y = d.y/dd
            
            var r = state.origin
            var v = state.speed
            
            
            
            v = randumAddPoint(v)
            
//            if touchmode {
//                v = touchEffect(state: state)
//            }
            
            r.x = r.x + v.x / 5
            r.y = r.y + v.y / 5
            if (r.y > height) {r.y = height;v.y = 0} else if (r.y <= 5)    {r.y = 5; v.y = 0}
            if (r.x <= 5)     {r.x = 5; v.x = 0}     else if (r.x > width) {r.x = width;v.x = 0}
            
            let ret:LineState = LineState(r,v,d,l,life)
            return ret
        }
    }
    
    func touchEffect(state:State) -> CGPoint {
        var v : CGPoint = state.1
        if (state.0.x > touchPoint.x) {
            v.x = v.x - 1
        } else if (state.0.x < touchPoint.x) {
            v.x = v.x + 1
        }
        if (state.0.y > touchPoint.y) {
            v.y = v.y - 1
        } else if (state.0.y < touchPoint.y) {
            v.y = v.y + 1
        }
        
        return v
    }
    
    override func draw(_ rect: CGRect) {
        
        context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        context?.setLineWidth(3)
        context?.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
        context?.setLineCap(CGLineCap.round)
        
        for p in list! { drawLine(point: p.origin, direction: p.direction, length: p.length)}
    }

    func start() {
        
        list  = initialState(100,
                             point:center,
                             direction:CGPoint(x:0,y:1),
                                length:10,
                                life:5)
        Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(AnimalView.timeFired(_:)), userInfo: nil, repeats: true)
    }
    
    func timeFired(_ timer:Timer) {
        
        self.list =  update(self.list!)
        self.setNeedsLayout()
        self.setNeedsDisplay()
    }
    
    func initialState(_ n:NSInteger, point:CGPoint, direction:CGPoint, length:CGFloat, life:CGFloat)->[LineState]
    {
        var l:[LineState] = []
        for _ in 0 ... n {
            let state:LineState = LineState(point,
                                            dVec(x:0,y:0),
                                            direction,
                                            length,
                                            life)
            l.append(state)
        }
        return l
    }
}



class AnimalView2: UIView {
    
    var touchmode:Bool = false
    var touchPoint:CGPoint = CGPoint.zero
    
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchmode = true
        if let touch:UITouch = touches.first {
            let point = touch.location(in: self)
            touchPoint = point
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch:UITouch = touches.first {
            let point = touch.location(in: self)
            touchPoint = point
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchmode = false
    }
    
    func drawCircle(_ rect:CGRect) {
        
        context?.strokeEllipse(in: rect)
        context?.strokePath()
    }
    
    func drawCircle(_ point:CGPoint, radius:CGFloat) {
        
        let r = CGRect(x: point.x - radius, y: point.y - radius, width: radius*2, height: radius * 2)
        drawCircle(r)
    }
    
    func drawCirclePoint(_ point:CGPoint, r:Radius) {
        
        drawCircle(point, radius: r)
    }
    
    func update(_ list:[State]) -> [State] {

        let width = self.frame.width
        let height = self.frame.height
        
        return list.map { (state:State) -> State in
            
//            let dradius = state.3 + CGFloat(arc4random() % 3) - 1
//            var radius = state.2 + dradius/5
            let dradius = state.3
            let radius = state.2
//            var radius = state.2 + CGFloat(arc4random() % 3) - 1
//            if radius < 1 {
//                radius = 1
//            } else if radius > 10 {
//                radius = 10
//            }
            
            var r = state.0
            var v = state.1

            v = randumAddPoint(v)
            
            if touchmode {
                v = touchEffect(state: state)
            }
            
            r.x = r.x + v.x / 5
            r.y = r.y + v.y / 5
            if (r.y > height) {r.y = height;v.y = 0} else if (r.y <= 5)    {r.y = 5; v.y = 0}
            if (r.x <= 5)     {r.x = 5; v.x = 0}     else if (r.x > width) {r.x = width;v.x = 0}
            return (r,v, radius, dradius)
        }
    }
    
    func touchEffect(state:State) -> CGPoint {
        var v : CGPoint = state.1
        if (state.0.x > touchPoint.x) {
            v.x = v.x - 1
        } else if (state.0.x < touchPoint.x) {
            v.x = v.x + 1
        }
        if (state.0.y > touchPoint.y) {
            v.y = v.y - 1
        } else if (state.0.y < touchPoint.y) {
            v.y = v.y + 1
        }
        
        return v
    }
    
    override func draw(_ rect: CGRect) {
        
        context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        context?.setLineWidth(3)
        context?.setStrokeColor(red: 0, green: 0, blue: 1, alpha: 1)
        context?.setLineCap(CGLineCap.round)
        
        for p in list! { drawCirclePoint(p.0, r:p.2) }
    }
    
    func start() {
        
        self.list  = initialState(100,
                                  point:self.center,
                                  radius: 1)
        Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(AnimalView.timeFired(_:)), userInfo: nil, repeats: true)
    }
    
    func timeFired(_ timer:Timer) {
        
        self.list =  update(self.list!)
        self.setNeedsLayout()
        self.setNeedsDisplay()
    }
    
    func initialState(_ n:NSInteger, point:CGPoint, radius:CGFloat)->[State]
    {
        var l:[State] = []
        for _ in 0 ... n {
            let state:State = State(point,
                                    dVec(x:0,y:0),
                                    10,
                                    0)
            l.append(state)
        }
        return l
    }
}
