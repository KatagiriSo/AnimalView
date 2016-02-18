//
//  AnimalView.swift
//
//  Created by 片桐奏羽 on 2016/02/18.
//  Copyright (c) 2016年 SoKatagiri. 
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

import UIKit

func randumAddPoint(point:CGPoint) -> CGPoint{
    
    var x = point.x, y = point.y
    switch (rand() % 4) {
    case 0: x++
    case 1: y++
    case 2: x--
    case 3: y--
    default:
        break
    }
    
    return CGPoint(x:x, y:y);
}

typealias Vec = CGPoint
typealias dVec = CGPoint
typealias State = (Vec, dVec)

func initialState(n:NSInteger, point:CGPoint)->[State]
{
    var l:[State] = []
    for (var i = 0;i<n;i++) {
        var state:State = State(point, dVec(x:0,y:0))
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

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        start()
    }
    
    func drawLine(point:CGPoint, point2:CGPoint)
    {
        CGContextMoveToPoint(context, point.x, point.y)
        CGContextAddLineToPoint(context, point2.x, point2.y)
        CGContextStrokePath(context)
    }
    
    
    func drawCircle(rect:CGRect)
    {
        CGContextStrokeEllipseInRect(context, rect)
        CGContextStrokePath(context)
    }
    
    func drawCircle(point:CGPoint, radius:CGFloat)
    {
        let r = CGRectMake(point.x - radius, point.y - radius, radius*2, radius * 2)
        drawCircle(r)
    }
    
    func drawCirclePoint(point:CGPoint)
    {
        var r = CGFloat(rand() % 10+10)
        drawCircle(point, radius: r)
    }
    
    class func randumPoint()->(CGPoint)
    {
        let x:CGFloat = CGFloat(rand() % 200)
        let y:CGFloat = CGFloat(rand() % 400)
        return CGPoint(x: x, y: y)
    }
    
    func update(list:[State]) -> [State]
    {
        let width = self.frame.width
        let height = self.frame.height
        return list.map { (state:State) -> State in
            var r = state.0
            var v = state.1
            v = randumAddPoint(v)
            r.x = r.x + v.x / 5
            r.y = r.y + v.y / 5
            if (r.y > height) {r.y = height;v.y = 0}
            if (r.y <= 5) {r.y = 5;v.y = 0}
            if (r.x <= 5) {r.x = 5;v.x = 0}
            if (r.x > width) {r.x = width;v.x = 0}
            return (r,v)
        }
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        context = UIGraphicsGetCurrentContext()
        
        CGContextClearRect(context, rect)
        CGContextSetLineWidth(context, 3)
        CGContextSetRGBStrokeColor(context, 0, 0, 1, 1)
        CGContextSetLineCap(context, kCGLineCapRound )
        
        for p in list! {
            drawCirclePoint(p.0)
        }
        
    }
    
    func start()
    {
        self.list  = initialState(10, self.center)

        NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("timeFired:"), userInfo: nil, repeats: true)
    }
    
    func timeFired(timer:NSTimer)
    {
        self.list =  update(self.list!)
        self.setNeedsLayout()
        self.setNeedsDisplay()
    }
    
    
}




