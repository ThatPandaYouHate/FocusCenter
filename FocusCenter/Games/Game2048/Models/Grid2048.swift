import Foundation

struct Tile2048: Identifiable, Equatable {
    let id = UUID()
    var value: Int
    var row: Int
    var col: Int
}

enum Direction {
    case up, down, left, right
}

enum Game2048Status {
    case playing, won, lost
}
