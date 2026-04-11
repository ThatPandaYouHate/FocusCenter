import SwiftUI

@Observable
class NonogramViewModel {
    var puzzle: NonogramPuzzle
    var playerGrid: [[NonogramCellState]]
    var size: NonogramSize
    var isFillingMode: Bool = true
    var isGameWon: Bool = false
    var showWinAlert: Bool = false
    /// Unikt ID per genererat spel – garanterar att SwiftUI bygger om hela vyn.
    var gameID = UUID()

    init() {
        self.size = .small
        let p = NonogramPuzzle.generate(size: .small)
        self.puzzle = p
        self.playerGrid = Array(
            repeating: Array(repeating: NonogramCellState.empty, count: p.solution[0].count),
            count: p.solution.count
        )
    }

    func newGame(newSize: NonogramSize? = nil) {
        if let newSize { size = newSize }
        let p = NonogramPuzzle.generate(size: size)
        puzzle = p
        playerGrid = Array(
            repeating: Array(repeating: NonogramCellState.empty, count: p.solution[0].count),
            count: p.solution.count
        )
        isGameWon = false
        showWinAlert = false
        gameID = UUID()
    }

    func toggleCell(row: Int, col: Int) {
        guard !isGameWon,
              row < playerGrid.count,
              col < (playerGrid.first?.count ?? 0) else { return }

        if isFillingMode {
            playerGrid[row][col] = playerGrid[row][col] == .filled ? .empty : .filled
        } else {
            playerGrid[row][col] = playerGrid[row][col] == .crossed ? .empty : .crossed
        }
    }

    func checkWin() {
        guard playerGrid.count == size.rows,
              (playerGrid.first?.count ?? 0) == size.cols else { return }
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
