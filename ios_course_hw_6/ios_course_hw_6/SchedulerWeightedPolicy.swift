//
//  SchedulerWeightedPolicy.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 20.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import UIKit

class SchedulerWeightedPolicy: SchedulerPolicyProtocol {
    
    let queuesWeights: [Float]
    let numberOfQueues: Int
    
    required init(numberOfQueues: Int) {
        self.numberOfQueues = numberOfQueues
        let singleWeight = Float(1 / numberOfQueues)
        var qWeights = [Float]()
        for _ in 0..<numberOfQueues {
            qWeights.append(singleWeight)
        }
        self.queuesWeights = qWeights
    }
    
    init(numberOfQueues: Int, queuesWeights: [Float]) {
        assert(queuesWeights.count == numberOfQueues, "Number of weights don't match")
        let totalWeight = queuesWeights.reduce(0, {res, new in
            return res + new
        })
        print(totalWeight)
        assert(abs(1 - totalWeight) < FLT_EPSILON, "Weight must be 1 in total")
        self.numberOfQueues = numberOfQueues
        self.queuesWeights = queuesWeights
    }
    
    func next(params: [String: Any]? = nil) -> Int {
        let rand = Float(arc4random()) / Float(UINT32_MAX)
        //print(rand)
        
        var weight = Float(0)
        for i in 0..<numberOfQueues {
            weight += queuesWeights[i]
            if rand <= weight {
                return i
            }
        }
        
        return randomInt(min: 0, max: numberOfQueues - 1)
    }
}
