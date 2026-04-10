import SwiftUI

struct GameCardView: View {
    let game: GameType

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: game.icon)
                .font(.system(size: 36))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(iconBackground)
                )

            VStack(spacing: 4) {
                Text(game.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(game.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            DifficultyBadge(difficulty: game.difficulty)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var iconBackground: some ShapeStyle {
        switch game {
        case .solitaire:
            return Color.green.gradient
        case .minesweeper:
            return Color.blue.gradient
        case .game2048:
            return Color.orange.gradient
        case .nonogram:
            return Color.purple.gradient
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: GameDifficulty

    var body: some View {
        Text(difficulty.label)
            .font(.caption2.weight(.medium))
            .foregroundStyle(difficulty.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(difficulty.color.opacity(0.15))
            )
    }
}
