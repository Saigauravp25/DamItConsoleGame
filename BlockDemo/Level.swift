//
//  Level.swift
//  BlockDemo
//
//  Created by Saigaurav Purushothaman on 9/23/20.
//

import Foundation

class Level {
    var id: String
    var width: Int
    var height: Int
    var topOfDam: Int
    var grid: [[Block]]
    var player: Player
    var blockHeld: Block {
        return self.grid[self.player.x - 1][self.player.y]
    }
    
    init(levelData:LevelDataFormat) {
        let logs = levelData.logs
        let rocks = levelData.rocks
        let beaver = levelData.beaver
        self.width = levelData.width
        self.height = levelData.height + 1
        grid = []
        for r in 0 ..< self.height {
            var row: [Block] = []
            for c in 0 ..< self.width {
                let airBlock = Block(x: r, y: c, type: .air)
                row.append(airBlock)
            }
            self.grid.append(row)
        }
        var inDam = 0
        for logPos in logs {
            let log = Block(x: logPos.x + 1, y: logPos.y, type: .log)
            self.grid[log.x][log.y] = log
            inDam += 1
        }
        for rockPos in rocks {
            let rock = Block(x: rockPos.x + 1, y: rockPos.y, type: .rock)
            self.grid[rock.x][rock.y] = rock
            inDam += 1
        }
        self.topOfDam = self.height - inDam / self.width
        self.player = Player(x: beaver.x + 1, y: beaver.y, direction: .right, hasLog: false)
        self.grid[player.x][player.y] = player
        self.id = levelData.id
    }
    
    func movePlayer(direction:Direction) -> Bool {
        let dy = (direction == .right) ? 1 : -1
        let directionChanged = (self.player.direction != direction)
        self.player.direction = direction
        if self.player.y + 1 >= self.width || self.player.y - 1 < 0 {
            return false
        }
        let blockInFront = self.grid[self.player.x][self.player.y + dy]
        if blockInFront.type != .air {
            if directionChanged {
                return false
            }
            return self.movePlayerUp()
        }
        var lowestRow = 0
        for row in grid {
            let block = row[self.player.y + dy]
            if block.type == .air {
                lowestRow = block.x
            } else {
                break
            }
        }
        let replacedAirBlock1 = self.grid[lowestRow][self.player.y + dy]
        let replacedAirBlock2 = self.grid[lowestRow - 1][self.player.y + dy]
        self.swapBlocks(blockA: self.blockHeld, blockB: replacedAirBlock2)
        self.swapBlocks(blockA: self.player, blockB: replacedAirBlock1)
        return true
    }
    
    private func movePlayerUp() -> Bool {
        //  TODO: carried block may go out of bounds
        if self.blockHeld.x - 1 < 0 || self.player.y + 1 >= self.width || self.player.y - 1 < 0 {
            return false
        }
        let dy = (self.player.direction == .right) ? 1 : -1
        if self.grid[self.player.x][self.player.y + dy].type == .air {
            return false
        }
        let secondBlockAbove = grid[self.player.x - 2][self.player.y]
        swapBlocks(blockA: self.blockHeld, blockB: secondBlockAbove)
        swapBlocks(blockA: self.blockHeld, blockB: self.player)
        let moved = (self.player.direction == .right) ? self.movePlayer(direction: .right) : self.movePlayer(direction: .left)
        if !moved {
            let newSecondBlockAbove = self.blockHeld
            swapBlocks(blockA: self.player, blockB: secondBlockAbove)
            swapBlocks(blockA: secondBlockAbove, blockB: newSecondBlockAbove)
            return false
        } else {
            return true
        }
    }
    
    func playerToggleCarryLog() -> Bool {
        if !self.player.hasLog {
            return self.playerPickUpLog()
        } else {
            return self.playerThrowDownLog()
        }
    }
    
    private func playerPickUpLog() -> Bool {
        if self.player.x - 1 < 0 || self.player.y + 1 >= self.width || self.player.y - 1 < 0 {
            return false
        }
        let dy = (self.player.direction == .right) ? 1 : -1
        let sideBlock = self.grid[self.player.x][self.player.y + dy]
        let cornerBlock = self.grid[self.player.x - 1][self.player.y + dy]
        if (sideBlock.type == .log || sideBlock.type == .beaver) && cornerBlock.type == .air {
            self.player.hasLog = true
            self.swapBlocks(blockA: sideBlock, blockB: self.blockHeld)
            return true
        } else {
            return false
        }
    }
    
    private func playerThrowDownLog() -> Bool {
        if self.player.x - 1 < 0 || self.player.y + 1 >= self.width || self.player.y - 1 < 0 {
            return false
        }
        let dy = (self.player.direction == .right) ? 1 : -1
        let cornerBlock = self.grid[self.player.x - 1][self.player.y + dy]
        if cornerBlock.type == .air {
            var lowestAirBlock = cornerBlock
            for row in grid {
                let block = row[self.player.y + dy]
                if block.type == .air {
                    lowestAirBlock = block
                } else {
                    break
                }
            }
            self.swapBlocks(blockA: lowestAirBlock, blockB: self.blockHeld)
            self.player.hasLog = false
            return true
        } else {
            return false
        }
    }
    
    private func swapBlocks(blockA:Block, blockB:Block) {
        let blockAOldPos = (x:blockA.x, y:blockA.y)
        let blockBOldPos = (x:blockB.x, y:blockB.y)
        blockA.x = blockBOldPos.x
        blockA.y = blockBOldPos.y
        blockB.x = blockAOldPos.x
        blockB.y = blockAOldPos.y
        self.grid[blockAOldPos.x][blockAOldPos.y] = blockB
        self.grid[blockBOldPos.x][blockBOldPos.y] = blockA
    }
    
    private func dfs(visited:inout [[Bool]]) -> Bool {
        if visited[self.player.x][self.player.y] {
            return true
        }
        
        if self.playerToggleCarryLog() {
            _ = self.playerToggleCarryLog()
            return false
        }
        _ = self.playerToggleCarryLog()
        
        let right = self.movePlayer(direction: .right)
        if right {
            visited[self.player.x][self.player.y] = true
            let ret = dfs(visited: &visited)
            _ = self.movePlayer(direction: .left)
            if !ret {
                return false
            }
        }
        let left = self.movePlayer(direction: .left)
        if left {
            visited[self.player.x][self.player.y] = true
            let ret = dfs(visited: &visited)
            _ = self.movePlayer(direction: .right)
            if !ret {
                return false
            }
        }
        return true
    }
    
    func checkPlayerStuck() -> Bool {
        if self.player.hasLog {
            return false
        }
//        var visited: [[Bool]] = [[Bool]](repeating: [Bool](repeating: false, count: self.width), count: self.height)
//        return dfs(visited: &visited)
        
        if self.player.x - 1 >= 0 && self.player.y - 1 >= 0 {
            var y = self.player.y - 1
            while y - 1 >= 0 && self.grid[self.player.x][y].type == .air {
                y -= 1;
            }
            if(y >= 0) {
                let topLeftCorner = self.grid[self.player.x - 1][y]
                if topLeftCorner.type == .air {
                    return false
                }
            }
        }
        if self.player.x - 1 >= 0 && self.player.y + 1 < self.width {
            var y = self.player.y + 1
            while y + 1 < self.width && self.grid[self.player.x][y].type == .air {
                y += 1;
            }
            if(y < self.width) {
                let topRightCorner = self.grid[self.player.x - 1][y]
                if topRightCorner.type == .air {
                    return false
                } else {
                    print("Dam, you got stuck!")
                    return true
                }
            }
        }
        return true
    }
    
    func checkLevelComplete() -> Bool {
        let damTopRow = self.grid[self.topOfDam]
        for block in damTopRow {
            let type = block.type
            if type != .log && type != .rock {
                return false
            }
        }
        print("Dam good! Level Complete!")
        return true
    }
    
    func toString(showDescription:Bool, showBlockPositions:Bool) -> String {
        var levelDesign = ""
        if showDescription {
            levelDesign.append("\(self.id)\n")
            levelDesign.append("Height: \(self.height), Width: \(self.width)\n")
            levelDesign.append("Player: \(self.player.toString())\n")
        }
        for r in 0 ..< self.height {
            for c in 0 ..< self.width {
                let block = self.grid[r][c]
                levelDesign.append("\(block.blockSymbol(showPositions: showBlockPositions))")
            }
            levelDesign.append("\n")
        }
        return levelDesign
    }
}
