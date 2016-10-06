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
    
    func fillEllipse(r:CGRect) {
        CGContextFillEllipseInRect(self, r)
    }
    
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

func getRandomPoint(size:CGSize) -> CGPoint {
    let x = arc4random() % UInt32(size.width)
    let y = arc4random() % UInt32(size.height)
    let p = CGPoint(x:CGFloat(x),y:CGFloat(y))
    return p
}

typealias Vec = CGPoint
typealias dVec = CGPoint
typealias Radius = CGFloat
typealias dRadius = CGFloat


protocol State {
    var uid:String {get}
    var origin:Vec {get}
    var speed:Vec {get}
    
    func draw(v:AnimalView)
    
}

public protocol AnimalViewDelegate {
    func touch(view:AnimalView, uid:String)
}

public class AnimalView: UIView {
    
    public func makeCircle(uid:String, radius:CGFloat, color:UIColor, borderColor:UIColor = UIColor.whiteColor(), mode:CircleState.Mode = CircleState.Mode.floating) -> CircleState {
        let c = CircleState(uid: uid,
                            origin: getRandomPoint(self.frame.size),
                            speed: CGPointZero,
                            radius: radius,
                            radSpeed: 0,
                            borderColor: borderColor,
                            fillColor: color,
                            mode: .floating)
        return c
    }
    
    public struct CircleState : State {
        

        
        public enum Mode {
            case grouning,floating
        }
        
        let uid:String
        let origin:Vec
        let speed:dVec
        let radius:Radius
        let radSpeed:dRadius
        let borderColor:UIColor
        let fillColor:UIColor
        let mode:Mode
        

        
        func update(mode:Mode) -> CircleState
        {
            let c = CircleState(uid: uid,
                                origin: origin,
                                speed: speed,
                                radius: radius,
                                radSpeed: radSpeed,
                                borderColor: borderColor,
                                fillColor: fillColor,
                                mode: mode)
            return c
        }
        
        func contain(point:CGPoint) -> Bool {
            let d2 =  pow(origin.x-point.x,2) + pow(origin.y - point.y,2)
            let r2 = pow(radius,2)
            return d2 <= r2
        }
        
        var tuple:(origin:Vec,speed:dVec,radius:Radius,radSpeed:dRadius, borderColor:UIColor, fillColor:UIColor, uid:String, mode:Mode) {
            return (origin:origin, speed:speed, radius:radius, radSpeed:radSpeed, borderColor:borderColor, fillColor:fillColor, uid:uid, mode:mode)
        }
        
        func draw(v: AnimalView) {
            v.drawCircle(self,origin:self.origin, radius: self.radius, borderColor: self.borderColor, fillColor: self.fillColor);
        }
    }
    
    struct LineState : State {
        let uid:String
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

    
    public enum StateConfig {
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

    var touchmode:Bool = false
    var touchPoint:CGPoint?
    
    var list:[State]? = []
    public var config:StateConfig = .circle
    
    var context:CGContext? = nil
    var currentGrow:CircleState? = nil
    var currentCatch:CircleState? = nil
    
    let timeinterval = 0.016
    
    public var animalDelegate:AnimalViewDelegate?
    
    public func deleteAnimal(uid:String) {
        self.list = self.list?.filter({ s in
            if s.uid != uid {
                return true
            } else {
                return false
            }
        })
    }
    
    public func updateAnimalState(uid:String, mode:CircleState.Mode) {
        self.list = list?.map({ s  in
            if s.uid == uid {
                if let s = s as? CircleState {
                    return s.update(mode)
                }
            }
            return s
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        switch config {
        case .circle:
            list = initialState(1, point: touchPoint, radius:1)
        case .line:
            list = initialState(100, point: touchPoint, direction: CGPoint(x:10,y:1), length: 10, life: 5)
        }
    }
    
    public func start() {
        
        self.multipleTouchEnabled = true
        
        NSTimer.scheduledTimerWithTimeInterval(timeinterval, target: self, selector: #selector(AnimalView.timeFired(_:)), userInfo: nil, repeats: true)
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchmode = true
        if let touch:UITouch = touches.first {
            let point = touch.locationInView(self)
            touchPoint = point
        }
        
        if let list = list, let touchPoint = touchPoint {
            for s in list {
                if let s = s as? CircleState {
                    if s.contain(touchPoint) {
                        currentCatch = s
                        animalDelegate?.touch(self, uid: s.uid)
                    }
                }
            }
        }
        
        switch touches.count {
        case 1:
            break
        case 2:
            if let current = currentGrow, let list = list {
                self.list = list.map({ (s:State) -> State in
                    if s.uid == current.uid {
                        if let s = s as? CircleState {
                            return s.update(.floating)
                        }
                    }
                    return s
                })
                currentGrow = nil
                return
            }
            self.currentGrow = addCircle("\(list?.count)", point: self.center, radius: 10,borderColor: UIColor.random, fillColor: UIColor.random, mode: .grouning)
        case 3...5:
            config = config.toggle()
            setup()
        default:
            break
        }

    }
    
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch:UITouch = touches.first {
            let point = touch.location(self)
            touchPoint = point
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchmode = false
        currentCatch = nil
    }
    
    
    func drawCircle(rect:CGRect) {
        
        context?.fillEllipse(rect)
        context?.strokeEllipse(rect)
        context?.strokePath()
    }
    
    func drawCircle(state:CircleState, origin:CGPoint, radius:CGFloat, borderColor:UIColor, fillColor:UIColor) {
        
        let r = CGRect(x: origin.x - radius, y: origin.y - radius, width: radius*2, height: radius * 2)
        
        if let currentCatch = currentCatch {
            if currentCatch.uid == state.uid {
                CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
            } else {
                CGContextSetStrokeColorWithColor(context, fillColor.CGColor)
            }
        } else {
            CGContextSetStrokeColorWithColor(context, fillColor.CGColor)
        }
        
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
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
        
        let uid = state.uid
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
        
        let ret:LineState = LineState(uid:uid, origin: r, speed: v, direction: d, length: l, life: life)
        return ret
    }
    
    func update(state:CircleState) -> State {
        
        let width = self.frame.width
        let height = self.frame.height
        
        let uid = state.uid
        let borderColor = state.borderColor
        let fillColor = state.fillColor
        var dradius = state.radSpeed
        var radius = state.radius
        let mode = state.mode
        
        var r = state.origin
        var v = state.speed
        
        if state.mode == .floating {
            v = randumAddPoint(v)
        } else {
            v = CGPoint(x:0,y:0)
        }
        
        if mode == .grouning {
            dradius = 0.5 + 10 * 100 / (radius*radius)

            
        } else {
            dradius = 0
        }
        
        radius = radius + dradius / 5
        
        if touchmode {
            v = touchEffect(state, touchPoint: touchPoint ?? center)
        }
        
        var m:CGFloat = 5
        m = m + radius*radius / 10000
        if m > 100 {
            m = 100
        }
        
        r.x = r.x + v.x / m
        r.y = r.y + v.y / m
        if (r.y > height) {r.y = height;v.y = 0} else if (r.y <= 5)    {r.y = 5; v.y = 0}
        if (r.x <= 5)     {r.x = 5; v.x = 0}     else if (r.x > width) {r.x = width;v.x = 0}
        
        return CircleState(uid:uid, origin: r, speed: v, radius:radius, radSpeed:dradius,borderColor:borderColor, fillColor: fillColor, mode:mode)
    }
    
    func update(list:[State]) -> [State] {
        return list.map(update)
    }
    
    func touchEffect(state:State, touchPoint:CGPoint) -> CGPoint {
        
        if let currentCatch = currentCatch {
            if currentCatch.uid != state.uid {
                return state.speed
            }
        }
        
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
    
    override public func drawRect(rect: CGRect) {
        
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
        for i in 0 ... n {
            let state:LineState = LineState(uid:"\(i)",
                                            origin:point ?? center,
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
                                                borderColor:UIColor.random,
                                                fillColor:UIColor.random,
                                                mode:.floating
                                                )
            l.append(state)
        }
        return l
    }
    
    
    public func addCircle(state:CircleState) {
        list?.append(state)
    }
    

    
    
    public func addCircle(uid:String,
                   point:CGPoint?,
                   radius:CGFloat?,
                   borderColor:UIColor,
                   fillColor:UIColor,
                   mode:CircleState.Mode?) -> CircleState {
        
        var p:CGPoint
        if point == nil {
            p = getRandomPoint(self.frame.size)
        } else {
            p = point!
        }
        
        let r:CGFloat = {
            if let radius = radius {
                return radius
            } else {
                return 10
            }
        }()
        
        let mode:CircleState.Mode = {
            if let mode = mode {
                return mode
            } else {
                return CircleState.Mode.floating
            }
        }()
        
        let state:CircleState = CircleState(uid: uid,
                                            origin: p,
                                            speed: CGPoint(x:0,y:0),
                                            radius: r,
                                            radSpeed: 0,
                                            borderColor: borderColor,
                                            fillColor:fillColor,
                                            mode: mode)
        list?.append(state)
        return state
    }
    


}
