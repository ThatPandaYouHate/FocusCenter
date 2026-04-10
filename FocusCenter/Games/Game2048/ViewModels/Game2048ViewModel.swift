import Foundation
import Observation

@Observable
class Game2048ViewModel {
    var grid: [[Int?]] = Array(repeating: Array(repeating: nil, count: 4), count: 4)
    var tiles: [Tile2048] = []
    var score: Int = 0
    var bestScore: Int = UserDefaults.standard.integer(forKey: "bestScore2048")
    var gameStatus: Game2048Status = .playing
    var hasWon2048: Bool = false
    var showWinAlert: Bool = false
    var showLoseAlert: Bool = false

    init() {
        newGame()
    }

    func newGame() {
        grid = Array(repeating: Array(repeating: nil, count: 4), count: 4)
        score = 0
        gameStatus = .playing
        showWinAlert = false
        showLoseAlert = false
        spawnTile()
        spawnTile()
        updateTiles()
    }

    func move(_ direction: Direction) {
        guard gameStatus != .lost else { return }

        let oldGrid = grid
        var mergeScore = 0

        switch direction {
        case .left:
            for r in 0..<4 {
                let row = grid[r].compactMap { $0 }
                let (merged, pts) = mergeRow(row)
                mergeScore += pts
                grid[r] = pad(merged)
            }
        case .right:
            for r in 0..<4 {
                let row = grid[r].compactMap { $0 }.reversed()
                let (merged, pts) = mergeRow(Array(row))
                mergeScore += pts
                grid[r] = pad(merged).reversed()
            }
        case .up:
            for c in 0..<4 {
                let col = (0..<4).compactMap { grid[$0][c] }
                let (merged, pts) = mergeRow(col)
                mergeScore += pts
                let padded = pad(merged)
                for r in 0..<4 { grid[r][c] = padded[r] }
            }
        case .down:
            for c in 0..<4 {
                let col = (0..<4).compactMap { grid[$0][c] }.reversed()
                let (merged, pts) = mergeRow(Array(col))
                mergeScore += pts
                let padded = pad(merged).reversed()
                for r in 0..<4 { grid[r][c] = Array(padded)[r] }
            }
        }

        guard grid != oldGrid else { return }

        score += mergeScore
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: "bestScore2048")
        }

        spawnTile()
        updateTiles()

        if !hasWon2048 && tiles.contains(where: { $0.value >= 2048 }) {
            hasWon2048 = true
            gameStatus = .won
            showWinAlert = true
        }

        if !canMove() {
            gameStatus = .lost
            showLoseAlert = true
        }
    }

    private func mergeRow(_ row: [Int]) -> ([Int], Int) {
        var result: [Int] = []
        var points = 0
        var i = 0
        while i < row.count {
            if i + 1 < row.count && row[i] == row[i + 1] {
                let merged = row[i] * 2
                result.append(merged)
                points += merged
                i += 2
            } else {
                result.append(row[i])
                i += 1
            }
        }
        return (result, points)
    }

    private func pad(_ row: [Int]) -> [Int?] {
        var padded: [Int?] = row.map { $0 }
        while padded.count < 4 { padded.append(nil) }
        return padded
    }

    func spawnTile() {
        var empties: [(Int, Int)] = []
        for r in 0..<4 {
            for c in 0..<4 {
                if grid[r][c] == nil { empties.append((r, c)) }
            }
        }
        guard let pos = empties.randomElement() else { return }
        grid[pos.0][pos.1] = Double.random(in: 0..<1) < 0.9 ? 2 : 4
    }

    func canMove() -> Bool {
        for r in 0..<4 {
            for c in 0..<4 {
                if grid[r][c] == nil { return true }
                if let val = grid[r][c] {
                    if r + 1 < 4 && grid[r + 1][c] == val { return true }
                    if c + 1 < 4 && grid[r][c + 1] == val { return true }
                }
            }
        }
        return false
    }

    private func updateTiles() {
        var newTiles: [Tile2048] = []
        for r in 0..<4 {
            for c in 0..<4 {
                if let val = grid[r][c] {
                    newTiles.append(Tile2048(value: val, row: r, col: c))
                }
            }
        }
        tiles = newTiles
    }
}
