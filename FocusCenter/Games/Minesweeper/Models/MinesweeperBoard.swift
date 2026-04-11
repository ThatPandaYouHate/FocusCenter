import Foundation

enum MinesweeperDifficulty: String, CaseIterable {
    case beginner
    case intermediate
    case expert

    var rows: Int {
        switch self {
        case .beginner: 9
        case .intermediate: 18
        case .expert: 30
        }
    }

    var cols: Int {
        switch self {
        case .beginner: 9
        case .intermediate: 14
        case .expert: 16
        }
    }

    var mineCount: Int {
        switch self {
        case .beginner: 10
        case .intermediate: 40
        case .expert: 99
        }
    }
}

enum MinesweeperGameStatus {
    case playing
    case won
    case lost
}
