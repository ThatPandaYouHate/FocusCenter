import SwiftUI

struct TableauPileView: View {
    let cards: [Card]
    let pileIndex: Int
    let cardWidth: CGFloat
    let viewModel: SolitaireViewModel
    private let faceDownOffset: CGFloat = 8
    private let faceUpOffset: CGFloat = 20
    private let tapVsDragThreshold: CGFloat = 10

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
                tableauCard(index: index, card: card)
            }
        }
        .frame(width: cardWidth, height: totalHeight, alignment: .top)
        .solitaireDropZone(.tableau(pileIndex))
        .overlay {
            RoundedRectangle(cornerRadius: cardWidth * 0.1)
                .stroke(
                    Color.yellow.opacity(viewModel.hoveredDrop == .tableau(pileIndex) ? 0.85 : 0),
                    lineWidth: 2
                )
        }
    }

    @ViewBuilder
    private func tableauCard(index: Int, card: Card) -> some View {
        let base = CardView(
            card: card,
            width: cardWidth,
            isSelected: viewModel.isSelected(location: .tableau(pileIndex), cardIndex: index)
        )
        .offset(y: yOffset(for: index))
        .zIndex(Double(index))
        .sensoryFeedback(.selection, trigger: viewModel.selection)

        if card.isFaceUp {
            base
                .opacity(viewModel.tableauDragOpacity(column: pileIndex, cardIndex: index))
                .simultaneousGesture(
                    TapGesture(count: 2).onEnded { _ in
                        viewModel.cancelActiveDrag()
                        withAnimation(.snappy) {
                            viewModel.handleDoubleTap(location: .tableau(pileIndex), cardIndex: index)
                        }
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named(SolitaireBoardLayout.coordinateSpaceName))
                        .onChanged { value in
                            if viewModel.activeDrag == nil {
                                viewModel.beginTableauDrag(
                                    column: pileIndex,
                                    startIndex: index,
                                    cardWidth: cardWidth,
                                    dragStartLocation: value.startLocation
                                )
                            }
                            viewModel.updateDrag(location: value.location)
                        }
                        .onEnded { value in
                            let moved = hypot(value.translation.width, value.translation.height)
                            guard viewModel.activeDrag != nil else { return }
                            if moved < tapVsDragThreshold {
                                viewModel.cancelActiveDrag()
                                withAnimation(.snappy) {
                                    viewModel.handleTap(location: .tableau(pileIndex), cardIndex: index)
                                }
                            } else {
                                viewModel.commitDrag(at: value.location)
                            }
                        }
                )
        } else {
            base
        }
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
