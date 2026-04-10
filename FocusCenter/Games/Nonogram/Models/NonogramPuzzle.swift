import Foundation

enum NonogramCellState {
    case empty, filled, crossed
}

enum NonogramSize: CaseIterable {
    case small, medium, large

    var rows: Int {
        switch self {
        case .small: 5
        case .medium: 10
        case .large: 15
        }
    }

    var cols: Int { rows }

    var label: String {
        "\(rows)x\(cols)"
    }
}

struct NonogramPuzzle {
    let solution: [[Bool]]
    let rowClues: [[Int]]
    let colClues: [[Int]]

    static func generate(size: NonogramSize) -> NonogramPuzzle {
        let rows = size.rows
        let cols = size.cols
        var grid = [[Bool]]()

        func randomRow() -> [Bool] {
            (0..<cols).map { _ in Double.random(in: 0...1) < Double.random(in: 0.55...0.65) }
        }

        func randomCol(in grid: [[Bool]], col: Int) -> Bool {
            grid.contains { $0[col] }
        }

        grid = (0..<rows).map { _ in randomRow() }

        // Re-randomize any fully empty rows
        for r in 0..<rows {
            while !grid[r].contains(true) {
                grid[r] = randomRow()
            }
        }

        // Ensure no column is completely empty
        for c in 0..<cols {
            if !randomCol(in: grid, col: c) {
                let randomRow = Int.random(in: 0..<rows)
                grid[randomRow][c] = true
            }
        }

        let rowClues = grid.map { row in computeClues(for: row) }

        let colClues = (0..<cols).map { c in
            let colValues = (0..<rows).map { r in grid[r][c] }
            return computeClues(for: colValues)
        }

        return NonogramPuzzle(solution: grid, rowClues: rowClues, colClues: colClues)
    }

    private static func computeClues(for line: [Bool]) -> [Int] {
        var clues = [Int]()
        var count = 0
        for val in line {
            if val {
                count += 1
            } else if count > 0 {
                clues.append(count)
                count = 0
            }
        }
        if count > 0 {
            clues.append(count)
        }
        return clues.isEmpty ? [0] : clues
    }
}
