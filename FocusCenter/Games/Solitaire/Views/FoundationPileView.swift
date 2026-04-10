import SwiftUI

struct FoundationPileView: View {
    let cards: [Card]
    let foundationIndex: Int
    let cardWidth: CGFloat
    let viewModel: SolitaireViewModel

    private static let suitSymbols = ["\u{2665}", "\u{2666}", "\u{2663}", "\u{2660}"]

    private let tapVsDragThreshold: CGFloat = 10

    private var cardHeight: CGFloat { cardWidth * 1.4 }

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
                .opacity(viewModel.foundationDragOpacity(foundationIndex: foundationIndex))
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named(SolitaireBoardLayout.coordinateSpaceName))
                        .onChanged { value in
                            if viewModel.activeDrag == nil {
                                viewModel.beginFoundationDrag(
                                    foundationIndex: foundationIndex,
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
                                viewModel.handleTap(
                                    location: .foundation(foundationIndex),
                                    cardIndex: cards.count - 1
                                )
                            } else {
                                viewModel.commitDrag(at: value.location)
                            }
                        }
                )
            }
        }
        .frame(width: cardWidth, height: cardHeight, alignment: .top)
        .solitaireDropZone(.foundation(foundationIndex))
        .overlay {
            RoundedRectangle(cornerRadius: cardWidth * 0.1)
                .stroke(
                    Color.yellow.opacity(viewModel.hoveredDrop == .foundation(foundationIndex) ? 0.85 : 0),
                    lineWidth: 2
                )
        }
        .onTapGesture {
            viewModel.handleTap(
                location: .foundation(foundationIndex),
                cardIndex: cards.isEmpty ? nil : cards.count - 1
            )
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
        .frame(width: cardWidth, height: cardHeight)
    }
}
