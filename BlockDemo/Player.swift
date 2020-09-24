//
//  Player.swift
//  BlockDemo
//
//  Created by Saigaurav Purushothaman on 9/23/20.
//

import Foundation

class Player: Block {
    var direction: Direction
    var hasLog: Bool
    
    init(x:Int, y:Int, direction:Direction, hasLog:Bool) {
        self.direction = direction
        self.hasLog = hasLog
        super.init(x: x, y: y, type: .beaver)
    }
    
    override func toString() -> String {
        return "X: \(self.x), Y: \(self.y), Direction: \(self.direction), Has Log: \(self.hasLog)"
    }
}
