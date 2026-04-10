import SwiftUI

struct NonogramGridCellView: View {
    let state: NonogramCellState
    let size: CGFloat
    var isCorrectlyFilled: Bool = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(fillColor)
                .frame(width: size, height: size)
                .border(Color.gray.opacity(0.4), width: 0.5)

            if state == .crossed {
                Image(systemName: "xmark")
                    .font(.system(size: size * 0.45, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var fillColor: Color {
        switch state {
        case .empty:
            return Color(.systemBackground)
        case .filled:
            return isCorrectlyFilled ? .green : Color.primary
        case .crossed:
            return Color(.systemBackground)
        }
    }
}
