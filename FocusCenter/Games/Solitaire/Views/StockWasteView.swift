import SwiftUI

struct StockPileView: View {
    let stock: [Card]
    let cardWidth: CGFloat
    let viewModel: SolitaireViewModel

    private var cardHeight: CGFloat { cardWidth * 1.4 }

    var body: some View {
        ZStack(alignment: .top) {
            if stock.isEmpty {
                resetPlaceholder
            } else {
                CardView(card: stock.last, width: cardWidth)
            }
        }
        .frame(width: cardWidth, height: cardHeight, alignment: .top)
        .onTapGesture {
            withAnimation(.snappy) {
                viewModel.handleTap(location: .stock, cardIndex: nil)
            }
        }
    }

    private var resetPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cardWidth * 0.1)
                .strokeBorder(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                .frame(width: cardWidth, height: cardHeight)
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: cardWidth * 0.3))
                .foregroundStyle(.white.opacity(0.3))
        }
    }
}

struct WastePileView: View {
    let waste: [Card]
    let cardWidth: CGFloat
    let viewModel: SolitaireViewModel

    private var cardHeight: CGFloat { cardWidth * 1.4 }
    private let tapVsDragThreshold: CGFloat = 10

    var body: some View {
        ZStack(alignment: .top) {
            CardView(card: nil, width: cardWidth, isPlaceholder: true)
            if let topCard = waste.last {
                CardView(
                    card: topCard,
                    width: cardWidth,
                    isSelected: viewModel.isSelected(location: .waste, cardIndex: waste.count - 1)
                )
                .opacity(viewModel.wasteDragOpacity())
                .simultaneousGesture(
                    TapGesture(count: 2).onEnded { _ in
                        viewModel.cancelActiveDrag()
                        withAnimation(.snappy) {
                            viewModel.handleDoubleTap(location: .waste, cardIndex: waste.count - 1)
                        }
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named(SolitaireBoardLayout.coordinateSpaceName))
                        .onChanged { value in
                            if viewModel.activeDrag == nil {
                                viewModel.beginWasteDrag(
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
                                    viewModel.handleTap(location: .waste, cardIndex: waste.count - 1)
                                }
                            } else {
                                viewModel.commitDrag(at: value.location)
                            }
                        }
                )
            }
        }
        .frame(width: cardWidth, height: cardHeight, alignment: .top)
        .solitaireDropZone(.waste)
    }
}
