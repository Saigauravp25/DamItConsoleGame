//
//  Block.swift
//  BlockDemo
//
//  Created by Saigaurav Purushothaman on 9/23/20.
//

import Foundation

//Representation of each block in the game grid
class Block {
    var x: Int
    var y: Int
    var type: BlockType
    
    init(x:Int, y:Int, type:BlockType) {
        self.x = x
        self.y = y
        self.type = type
    }
    
    //For debugging
    func toString() -> String {
        return "X: \(self.x), Y: \(self.y), Type: \(self.type)"
    }
    
    //Prints symbol of each block - for debugging
    func blockSymbol(showPositions: Bool) -> String {
        var pos = ""
        if showPositions {
            pos.append("\((x, y))")
        }
        switch type {
        case .air:
            return "🟦\(pos)"
        case .log:
            return "🟫\(pos)"
        case .rock:
            return "⬜️\(pos)"
        case .beaver:
            let player = self as! Player
            let direction = player.direction
            return direction == .right ? "▶️\(pos)" : "◀️\(pos)"
        }
    }
}
