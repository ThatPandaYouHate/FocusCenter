import SwiftUI

struct FoundationPileView: View {
    let cards: [Card]
    let foundationIndex: Int
    let cardWidth: CGFloat
    let viewModel: SolitaireViewModel

    private static let suitSymbols = ["♥", "♦", "♣", "♠"]

    var body: some View {
        ZStack(alignment: .top) {
            foundationPlaceholder
            if let topCard = cards.last {
                CardView(
                    card: topCard,
                    width: cardWidth,
                    isSelected: viewModel.isSelected(
                        location: .foundation(foundationIndex),
                        cardIndex: cards.count - 1
                    )
                )
                .onTapGesture {
                    viewModel.handleTap(location: .foundation(foundationIndex), cardIndex: cards.count - 1)
                }
            }
        }
        .onTapGesture {
            viewModel.handleTap(location: .foundation(foundationIndex), cardIndex: cards.isEmpty ? nil : cards.count - 1)
        }
    }

    private var foundationPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cardWidth * 0.1)
                .strokeBorder(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
            Text(Self.suitSymbols[foundationIndex])
                .font(.system(size: cardWidth * 0.35))
                .foregroundStyle(.white.opacity(0.1))
        }
        .frame(width: cardWidth, height: cardWidth * 1.4)
    }
}
