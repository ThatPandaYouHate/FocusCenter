import SwiftUI

struct TableauPileView: View {
    let cards: [Card]
    let pileIndex: Int
    let cardWidth: CGFloat
    let viewModel: SolitaireViewModel
    private let faceDownOffset: CGFloat = 8
    private let faceUpOffset: CGFloat = 20

    var body: some View {
        ZStack(alignment: .top) {
            CardView(card: nil, width: cardWidth, isPlaceholder: true)
                .allowsHitTesting(cards.isEmpty)
                .frame(width: cardWidth, height: cardWidth * 1.4)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.handleTap(location: .tableau(pileIndex), cardIndex: nil)
                }

            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                CardView(
                    card: card,
                    width: cardWidth,
                    isSelected: viewModel.isSelected(location: .tableau(pileIndex), cardIndex: index)
                )
                .offset(y: yOffset(for: index))
                .zIndex(Double(index))
                .onTapGesture(count: 2) {
                    withAnimation(.snappy) {
                        viewModel.handleDoubleTap(location: .tableau(pileIndex), cardIndex: index)
                    }
                }
                .onTapGesture {
                    withAnimation(.snappy) {
                        viewModel.handleTap(location: .tableau(pileIndex), cardIndex: index)
                    }
                }
                .sensoryFeedback(.selection, trigger: viewModel.selection)
            }
        }
        .frame(width: cardWidth, height: totalHeight, alignment: .top)
    }

    private func yOffset(for index: Int) -> CGFloat {
        var offset: CGFloat = 0
        for i in 0..<index {
            offset += cards[i].isFaceUp ? faceUpOffset : faceDownOffset
        }
        return offset
    }

    private var totalHeight: CGFloat {
        guard !cards.isEmpty else { return cardWidth * 1.4 }
        var height: CGFloat = cardWidth * 1.4
        for i in 0..<cards.count - 1 {
            height += cards[i].isFaceUp ? faceUpOffset : faceDownOffset
        }
        return height
    }
}
