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

extension UIColor {
    static var random:UIColor {
        let index = arc4random() % 8
        switch index {
        case 0:
            return UIColor.whiteColor()
        case 1:
            return UIColor.blueColor()
        case 2:
            return UIColor.redColor()
        case 3:
            return UIColor.greenColor()
        case 4:
            return UIColor.yellowColor()
        case 5:
            return UIColor.purpleColor()
        case 6:
            return UIColor.brownColor()
        case 7:
            return UIColor.orangeColor()
        default:
            assert(false, "bad index \(index)")
            return UIColor.cyanColor()
        }
    }
}

extension UITouch {
    func location(v:UIView) -> CGPoint {
        return self.locationInView(v)
    }
}

extension CGContext {
    func strokeEllipse(r:CGRect) {
        CGContextStrokeEllipseInRect(self, r)
    }
    
    func strokePath() {
        CGContextStrokePath(self)
    }
    
    func move(p:CGPoint) {
        CGContextMoveToPoint(self, p.x, p.y)
    }
    
    func addLine(toP:CGPoint) {
        CGContextAddLineToPoint(self, toP.x, toP.y)
    }
    
    func clear(r:CGRect) {
        CGContextClearRect(self, r)
    }
    
    func setLineWidth(w:CGFloat) {
        CGContextSetLineWidth(self, w)
    }
    
    func setStrokeColor(red: CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) {
        CGContextSetStrokeColor(self, [red,green,blue,alpha])
    }
    
    func setLineCap(index:CGLineCap) {
        CGContextSetLineCap(self, index)
    }
}

func randumAddPoint(point:CGPoint) -> CGPoint {
    
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

protocol State {
    var origin:Vec {get}
    var speed:Vec {get}
    
    func draw(v:AnimalView)
    
}

enum StateConfig {
    case line,circle
    
    func toggle()->StateConfig
    {
        switch self {
        case .line:
            return .circle
        case .circle:
            return .line
        }
    }
}

struct CircleState : State {
    let uid:String
    let origin:Vec
    let speed:dVec
    let radius:Radius
    let radSpeed:dRadius
    let color:UIColor
    
    var tuple:(origin:Vec,speed:dVec,radius:Radius,radSpeed:dRadius, color:UIColor, uid:String) {
        return (origin:origin, speed:speed, radius:radius, radSpeed:radSpeed, color:color, uid:uid)
    }
    
    func draw(v: AnimalView) {
        v.drawCircle(self.origin, radius: self.radius, color:self.color)
    }
}

struct LineState : State {
    let origin:Vec
    let speed:dVec
    let direction:Vec
    let length:CGFloat
    let life:CGFloat
    
    var tuple:(origin:Vec, speed:dVec, direction:Vec, length:CGFloat, life:CGFloat) {
        return (origin:origin, speed:speed, direction:direction, length:length, life:life)
    }
    
    func draw(v:AnimalView) {
        v.drawLine(self.origin, direction: self.direction, length: self.length)
    }
}


class AnimalView: UIView {

    var touchmode:Bool = false
    var touchPoint:CGPoint?
    
    var list:[State]? = []
    var config:StateConfig = .circle
    
    var context:CGContext? = nil
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        start()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        start()
    }
    
    func setup() {
        switch config {
        case .circle:
            list = initialState(100, point: touchPoint, radius:1)
        case .line:
            list = initialState(100, point: touchPoint, direction: CGPoint(x:10,y:1), length: 10, life: 5)
        }
    }
    
    func start() {
        
        self.multipleTouchEnabled = true
        
        setup()
        NSTimer.scheduledTimerWithTimeInterval(0.016, target: self, selector: #selector(AnimalView.timeFired(_:)), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchmode = true
        if let touch:UITouch = touches.first {
            let point = touch.locationInView(self)
            touchPoint = point
        }
        
        switch touches.count {
        case 1:
            break
        case 2...5:
            config = config.toggle()
            setup()
        default:
            break
        }

    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch:UITouch = touches.first {
            let point = touch.location(self)
            touchPoint = point
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchmode = false
    }
    
    
    func drawCircle(rect:CGRect) {
        
        context?.strokeEllipse(rect)
        context?.strokePath()
    }
    
    func drawCircle(point:CGPoint, radius:CGFloat, color:UIColor) {
        
        let r = CGRect(x: point.x - radius, y: point.y - radius, width: radius*2, height: radius * 2)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        drawCircle(r)
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
        
        context?.move(fromP)
        context?.addLine(toP)
        context?.strokePath()
        
    }
    
    func update(state:State) -> State {
        if let state = state as? LineState {
            return update(state)
        }
        
        if let state = state as? CircleState {
            return update(state)
        }
        return state
    }
    
    func update(state:LineState) -> State {
        
        let width = self.frame.width
        let height = self.frame.height
        
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
        
        if touchmode {
            v = touchEffect(state, touchPoint: touchPoint ?? center)
        }
        
        r.x = r.x + v.x / 5
        r.y = r.y + v.y / 5
        if (r.y > height) {r.y = height;v.y = 0} else if (r.y <= 5)    {r.y = 5; v.y = 0}
        if (r.x <= 5)     {r.x = 5; v.x = 0}     else if (r.x > width) {r.x = width;v.x = 0}
        
        let ret:LineState = LineState(origin: r, speed: v, direction: d, length: l, life: life)
        return ret
    }
    
    func update(state:CircleState) -> State {
        
        let width = self.frame.width
        let height = self.frame.height
        
        let uid = state.uid
        let color = state.color
        let dradius = state.radSpeed
        let radius = state.radius
        
        var r = state.origin
        var v = state.speed
        
        v = randumAddPoint(v)
        
        if touchmode {
            v = touchEffect(state, touchPoint: touchPoint ?? center)
        }
        
        r.x = r.x + v.x / 5
        r.y = r.y + v.y / 5
        if (r.y > height) {r.y = height;v.y = 0} else if (r.y <= 5)    {r.y = 5; v.y = 0}
        if (r.x <= 5)     {r.x = 5; v.x = 0}     else if (r.x > width) {r.x = width;v.x = 0}
        return CircleState(uid:uid, origin: r, speed: v, radius:radius, radSpeed:dradius, color: color)
    }
    
    func update(list:[State]) -> [State] {
        return list.map(update)
    }
    
    func touchEffect(state:State, touchPoint:CGPoint) -> CGPoint {
        var v : CGPoint = state.speed
        if (state.origin.x > touchPoint.x) {
            v.x = v.x - 1
        } else if (state.origin.x < touchPoint.x) {
            v.x = v.x + 1
        }
        if (state.origin.y > touchPoint.y) {
            v.y = v.y - 1
        } else if (state.origin.y < touchPoint.y) {
            v.y = v.y + 1
        }
        
        return v
    }
    
    override func drawRect(rect: CGRect) {
        
        context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        context?.setLineWidth(3)
        context?.setStrokeColor(1, green: 1, blue: 1, alpha: 1)
        context?.setLineCap(CGLineCap.Round)
        
        for p in list! { p.draw(self)}
    }


    
    func timeFired(timer:NSTimer) {
        
        self.list =  update(self.list!)
        self.setNeedsLayout()
        self.setNeedsDisplay()
    }
    
    func initialState(n:NSInteger, point:CGPoint?, direction:CGPoint, length:CGFloat, life:CGFloat)->[State]
    {
        var l:[State] = []
        for _ in 0 ... n {
            let state:LineState = LineState(origin:point ?? center,
                                            speed:dVec(x:0,y:0),
                                            direction:direction,
                                            length:length,
                                            life:life)
            l.append(state)
        }
        return l
    }
    
    func initialState(n:NSInteger, point:CGPoint?, radius:CGFloat)->[State]
    {
        var l:[State] = []
        for i in 0 ... n {
            let state:CircleState = CircleState(uid:"\(i)",
                                                origin: point ?? center,
                                                speed:dVec(x:0,y:0),
                                                radius:10,
                                                radSpeed:0,
                                                color:UIColor.random
                                                )
            l.append(state)
        }
        return l
    }
}
