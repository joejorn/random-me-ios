//
//  RandomizerHelper.swift
//  RandomMe
//
//  Created by Joe on 15.09.17.
//
//

import Foundation

class Randomizer: NSObject {
    
    private let TIME_INTERVAL: Double = 5.0
    private let MIN_ITERATIONS: Int = 30
    
    private var timer: Timeout? = nil
    var items = [Any]()
    
    private var changing: ( (Any?) -> Void )?
    private var completion: ( (Any?) -> Void )?
    
    init(items: [Any], onChanges changing: @escaping (Any?) -> Void, onComplete completion: @escaping (Any?) -> Void) {
        
        self.items = items
        self.changing = changing
        self.completion = completion
    }
    
    func reloadItems(_ _items: [Any]) {
        
        if timer != nil {
            timer!.cancel()
        }
        
        items = _items
    }
    
    func randomize() {
        
        guard items.count > 1 else {
            self.completion?(nil)
            return 
        }
        
        // random iteration number
        var iter = items.count;
        while (iter < MIN_ITERATIONS) {
            iter += (items.count * Int(arc4random_uniform(10))) + Int(arc4random_uniform(10));
        }
        timerFn(iter: 0, maxIter: iter);
    }
    
    func cancel() {
        guard let _timer = timer else { return }
        _timer.cancel()
    }
    
    private func timerFn(iter: Int, maxIter: Int, currentTime: Double = 0.0) {
        
        let nextTime = easingFn(iter: iter, changeValue: TIME_INTERVAL, total: maxIter);
        let duration: Double = nextTime - currentTime;
        
        // current content
        let currentIndex = iter % self.items.count
        let currentItem = self.items[currentIndex]
        
        // callback - on change
        if let _changing = changing {
            _changing(currentItem)
        }
        
        let newIter = iter + 1
        if (newIter <= maxIter) {
            self.timer = Timeout( duration, { () in
                self.timerFn(iter: newIter, maxIter: maxIter, currentTime: nextTime)
            });
            
        } else if let _completion = completion {
            self.timer = Timeout(0.5, { () in _completion(currentItem) });
        }
    }
    
    private func easingFn(iter currentIteration:Int, changeValue changeInValue:Double, total totalIterations:Int) -> Double {
        
        // easeInQuart
        let t = Double(currentIteration)/Double(totalIterations)
        let val = changeInValue * pow(t, 4.0)
        
        return val;
    }
    
    
}
