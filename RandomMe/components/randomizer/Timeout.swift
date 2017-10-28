//
//  Timeout.swift
//  RandomMe
//
//  Created by Joe on 15.09.17.
//
//

import Foundation

class Timeout: NSObject
{
    private var timer: Timer?
	private var callback: (() -> Void)?
    
	init(_ delaySeconds: Double, _ callback: @escaping (() -> Void) )
    {
        super.init()
        self.callback = callback
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(delaySeconds),
            target: self, selector: #selector(Timeout.invoke), userInfo: nil, repeats: false)
    }
    
	@objc func invoke()
    {
		self.callback?()
        // Discard callback and timer.
        self.callback = nil
        self.timer = nil
    }
    
    func cancel()
    {
        self.timer?.invalidate()
        self.timer = nil
    }
}
