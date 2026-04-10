import SwiftUI

enum GameType: String, CaseIterable, Identifiable, Hashable {
    case solitaire
    case minesweeper
    case game2048
    case nonogram

    var id: String { rawValue }

    var name: String {
        switch self {
        case .solitaire: "Patiens"
        case .minesweeper: "Minesweeper"
        case .game2048: "2048"
        case .nonogram: "Nonogram"
        }
    }

    var description: String {
        switch self {
        case .solitaire: "Klassisk Klondike-patiens med draw 1 eller 3"
        case .minesweeper: "Hitta alla minor utan att klicka på dem"
        case .game2048: "Skjut och slå ihop brickor till 2048"
        case .nonogram: "Lös pixelpussel med ledtrådar"
        }
    }

    var icon: String {
        switch self {
        case .solitaire: "suit.spade.fill"
        case .minesweeper: "square.grid.3x3.fill"
        case .game2048: "number.square.fill"
        case .nonogram: "rectangle.split.3x3.fill"
        }
    }

    var difficulty: GameDifficulty {
        switch self {
        case .solitaire: .medium
        case .minesweeper: .medium
        case .game2048: .medium
        case .nonogram: .medium
        }
    }

    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .solitaire: SolitaireView()
        case .minesweeper: MinesweeperView()
        case .game2048: Game2048View()
        case .nonogram: NonogramView()
        }
    }
}
