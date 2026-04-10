import SwiftUI

@Observable
class NonogramViewModel {
    var puzzle: NonogramPuzzle
    var playerGrid: [[NonogramCellState]]
    var size: NonogramSize
    var isFillingMode: Bool = true
    var isGameWon: Bool = false
    var showWinAlert: Bool = false

    init() {
        self.size = .small
        let p = NonogramPuzzle.generate(size: .small)
        self.puzzle = p
        self.playerGrid = Array(
            repeating: Array(repeating: NonogramCellState.empty, count: p.solution[0].count),
            count: p.solution.count
        )
    }

    func newGame() {
        isGameWon = false
        showWinAlert = false
        puzzle = NonogramPuzzle.generate(size: size)
        playerGrid = Array(
            repeating: Array(repeating: NonogramCellState.empty, count: size.cols),
            count: size.rows
        )
    }

    func toggleCell(row: Int, col: Int) {
        guard !isGameWon else { return }

        if isFillingMode {
            playerGrid[row][col] = playerGrid[row][col] == .filled ? .empty : .filled
        } else {
            playerGrid[row][col] = playerGrid[row][col] == .crossed ? .empty : .crossed
        }
    }

    func checkWin() {
        for r in 0..<size.rows {
            for c in 0..<size.cols {
                let isFilled = playerGrid[r][c] == .filled
                let shouldBeFilled = puzzle.solution[r][c]
                if isFilled != shouldBeFilled {
                    return
                }
            }
        }
        isGameWon = true
        showWinAlert = true
    }

    var maxRowClueCount: Int {
        puzzle.rowClues.map(\.count).max() ?? 1
    }

    var maxColClueCount: Int {
        puzzle.colClues.map(\.count).max() ?? 1
    }
}
