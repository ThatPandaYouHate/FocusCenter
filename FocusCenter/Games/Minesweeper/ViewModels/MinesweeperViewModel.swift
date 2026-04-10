import Foundation
import Observation

@Observable
class MinesweeperViewModel {
    var cells: [[MinesweeperCell]] = []
    var difficulty: MinesweeperDifficulty = .beginner
    var gameStatus: MinesweeperGameStatus = .playing
    var flagCount: Int = 0
    var isFirstTap: Bool = true
    var timer: Int = 0

    private var timerTask: Task<Void, Never>?

    var flagsRemaining: Int {
        difficulty.mineCount - flagCount
    }

    init() {
        newGame()
    }

    func newGame() {
        timerTask?.cancel()
        timerTask = nil
        gameStatus = .playing
        isFirstTap = true
        timer = 0
        flagCount = 0

        cells = (0..<difficulty.rows).map { row in
            (0..<difficulty.cols).map { col in
                MinesweeperCell(row: row, col: col)
            }
        }
    }

    func revealCell(row: Int, col: Int) {
        guard gameStatus == .playing,
              !cells[row][col].isRevealed,
              !cells[row][col].isFlagged else { return }

        if isFirstTap {
            isFirstTap = false
            placeMines(safeRow: row, safeCol: col)
            calculateAllAdjacentMines()
            startTimer()
        }

        cells[row][col].isRevealed = true

        if cells[row][col].isMine {
            gameStatus = .lost
            timerTask?.cancel()
            revealAllMines()
            return
        }

        if cells[row][col].adjacentMines == 0 {
            floodFillReveal(row: row, col: col)
        }

        checkWin()
    }

    func toggleFlag(row: Int, col: Int) {
        guard gameStatus == .playing,
              !cells[row][col].isRevealed else { return }

        cells[row][col].isFlagged.toggle()
        flagCount += cells[row][col].isFlagged ? 1 : -1
    }

    // MARK: - Private

    private func placeMines(safeRow: Int, safeCol: Int) {
        let safeCells = Set(
            neighbors(of: safeRow, safeCol).map { "\($0.0),\($0.1)" } + ["\(safeRow),\(safeCol)"]
        )

        var placed = 0
        while placed < difficulty.mineCount {
            let r = Int.random(in: 0..<difficulty.rows)
            let c = Int.random(in: 0..<difficulty.cols)

            if safeCells.contains("\(r),\(c)") || cells[r][c].isMine { continue }

            cells[r][c].isMine = true
            placed += 1
        }
    }

    private func calculateAllAdjacentMines() {
        for row in 0..<difficulty.rows {
            for col in 0..<difficulty.cols {
                guard !cells[row][col].isMine else { continue }
                cells[row][col].adjacentMines = neighbors(of: row, col)
                    .filter { cells[$0.0][$0.1].isMine }
                    .count
            }
        }
    }

    private func neighbors(of row: Int, _ col: Int) -> [(Int, Int)] {
        var result: [(Int, Int)] = []
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let nr = row + dr
                let nc = col + dc
                if nr >= 0, nr < difficulty.rows, nc >= 0, nc < difficulty.cols {
                    result.append((nr, nc))
                }
            }
        }
        return result
    }

    private func floodFillReveal(row: Int, col: Int) {
        for (nr, nc) in neighbors(of: row, col) {
            guard !cells[nr][nc].isRevealed, !cells[nr][nc].isFlagged else { continue }
            cells[nr][nc].isRevealed = true
            if cells[nr][nc].adjacentMines == 0 {
                floodFillReveal(row: nr, col: nc)
            }
        }
    }

    private func checkWin() {
        let won = cells.allSatisfy { row in
            row.allSatisfy { $0.isMine || $0.isRevealed }
        }
        if won {
            gameStatus = .won
            timerTask?.cancel()
        }
    }

    private func revealAllMines() {
        for row in 0..<difficulty.rows {
            for col in 0..<difficulty.cols where cells[row][col].isMine {
                cells[row][col].isRevealed = true
            }
        }
    }

    private func startTimer() {
        timerTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, self.gameStatus == .playing else { return }
                self.timer += 1
            }
        }
    }
}
