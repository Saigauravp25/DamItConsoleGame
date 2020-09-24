//
//  main.swift
//  BlockDemo
//
//  Created by Saigaurav Purushothaman on 9/22/20.
//

import Foundation

//Datatype for level structure. Each level grid may be represented in this format
typealias LevelDataFormat = (id: String, width: Int, height: Int, logs: [(x: Int,y: Int)], rocks: [(x: Int,y: Int)], beaver: (x: Int,y: Int))

let logList: [(x: Int,y: Int)] = [(0,0),(1,0),(2,0),(2,1),(3,1),(2,3),(3,3),(3,4),(2,7),(3,7),(1,8),(2,8),(3,8),(0,9),(1,9)]
let rockList: [(x: Int,y: Int)] = [(3,0),(2,5),(3,5),(2,9),(3,9)]
let beaverPos: (x: Int,y: Int) = (1,5)
let id: String = "Level 1"
let width = 10
let height = 4
let levelData: LevelDataFormat = (id, width, height, logList, rockList, beaverPos)

//Create a level
let level1 = Level(levelData: levelData)

print(level1.toString(showDescription: true, showBlockPositions: false))

//Game loop for command line app. iOS will be different
while !level1.checkLevelComplete() && !level1.checkPlayerStuck() {
    let response = readLine()!
    if response == "a" {
        _ = level1.movePlayer(direction: .left)
    } else if response == "d" {
        _ = level1.movePlayer(direction: .right)
    } else if response == "s" {
        _ = level1.playerToggleCarryLog()
    }
    //Print current state of the game
    print(level1.toString(showDescription: false, showBlockPositions: false))
}
