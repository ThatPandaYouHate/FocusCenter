import SwiftUI

struct SolitaireView: View {
    @State private var viewModel = SolitaireViewModel()

    var body: some View {
        GeometryReader { geo in
            let cardWidth = cardWidth(for: geo.size.width)
            let spacing = (geo.size.width - cardWidth * 7) / 8

            ScrollView {
                VStack(spacing: 16) {
                    topRow(cardWidth: cardWidth, spacing: spacing)
                        .padding(.horizontal, spacing)

                    tableauRow(cardWidth: cardWidth, spacing: spacing)
                        .padding(.horizontal, spacing)
                }
                .padding(.top, 8)
                .animation(.snappy, value: viewModel.tableau.map { $0.map(\.id) })
                .animation(.snappy, value: viewModel.foundations.map { $0.map(\.id) })
                .animation(.snappy, value: viewModel.waste.map(\.id))
            }
        }
        .background(Color(red: 0.1, green: 0.35, blue: 0.15))
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    withAnimation(.snappy) { viewModel.undo() }
                } label: {
                    Label("Ångra", systemImage: "arrow.uturn.backward")
                }
                .disabled(!viewModel.canUndo)

                Spacer()

                Picker("Draw", selection: Binding(
                    get: { viewModel.drawCount },
                    set: { newValue in
                        viewModel.drawCount = newValue
                        withAnimation(.snappy) { viewModel.newGame() }
                    }
                )) {
                    Text("Draw 1").tag(1)
                    Text("Draw 3").tag(3)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)

                Spacer()

                Button {
                    withAnimation(.snappy) { viewModel.newGame() }
                } label: {
                    Label("Nytt spel", systemImage: "arrow.clockwise")
                }
            }
        }
        .alert("Grattis!", isPresented: $viewModel.showWin) {
            Button("Nytt spel") {
                withAnimation(.snappy) { viewModel.newGame() }
            }
        } message: {
            Text("Du vann patiens!")
        }
    }

    private func cardWidth(for screenWidth: CGFloat) -> CGFloat {
        let width = (screenWidth - 8 * 6) / 7
        return min(width, 80)
    }

    private func topRow(cardWidth: CGFloat, spacing: CGFloat) -> some View {
        let cardHeight = cardWidth * 1.4
        return HStack(alignment: .top, spacing: spacing) {
            StockPileView(stock: viewModel.stock, cardWidth: cardWidth, viewModel: viewModel)
                .frame(width: cardWidth, height: cardHeight, alignment: .top)

            WastePileView(waste: viewModel.waste, cardWidth: cardWidth, viewModel: viewModel)
                .frame(width: cardWidth, height: cardHeight, alignment: .top)

            Color.clear
                .frame(width: cardWidth, height: cardHeight)

            ForEach(0..<4, id: \.self) { i in
                FoundationPileView(
                    cards: viewModel.foundations[i],
                    foundationIndex: i,
                    cardWidth: cardWidth,
                    viewModel: viewModel
                )
                .frame(width: cardWidth, height: cardHeight, alignment: .top)
            }
        }
    }

    private func tableauRow(cardWidth: CGFloat, spacing: CGFloat) -> some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(0..<7, id: \.self) { i in
                TableauPileView(
                    cards: viewModel.tableau[i],
                    pileIndex: i,
                    cardWidth: cardWidth,
                    viewModel: viewModel
                )
            }
        }
    }
}
