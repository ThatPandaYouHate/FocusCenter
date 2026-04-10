import Foundation

struct MinesweeperCell: Identifiable {
    let id = UUID()
    let row: Int
    let col: Int
    var isMine: Bool = false
    var isRevealed: Bool = false
    var isFlagged: Bool = false
    var adjacentMines: Int = 0
}
