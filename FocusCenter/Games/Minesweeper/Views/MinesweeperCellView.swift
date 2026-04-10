import SwiftUI

struct MinesweeperCellView: View {
    let cell: MinesweeperCell
    let cellSize: CGFloat
    let gameStatus: MinesweeperGameStatus

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundColor)
                .frame(width: cellSize, height: cellSize)

            if !cell.isRevealed && cell.isFlagged {
                Image(systemName: "flag.fill")
                    .foregroundStyle(.red)
                    .font(.system(size: cellSize * 0.5))
            } else if cell.isRevealed && cell.isMine {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: cellSize * 0.5))
            } else if cell.isRevealed && cell.adjacentMines > 0 {
                Text("\(cell.adjacentMines)")
                    .font(.system(size: cellSize * 0.55, weight: .bold, design: .monospaced))
                    .foregroundStyle(numberColor)
            }
        }
    }

    private var backgroundColor: Color {
        if !cell.isRevealed {
            return Color(.systemGray3)
        } else if cell.isMine {
            return .red
        } else {
            return Color(.systemGray5)
        }
    }

    private var numberColor: Color {
        switch cell.adjacentMines {
        case 1: .blue
        case 2: .green
        case 3: .red
        case 4: .purple
        case 5: Color(red: 0.5, green: 0, blue: 0)
        case 6: .teal
        case 7: .black
        case 8: .gray
        default: .clear
        }
    }
}
