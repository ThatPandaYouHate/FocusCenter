import SwiftUI

struct Game2048View: View {
    @State private var viewModel = Game2048ViewModel()

    var body: some View {
        GeometryReader { geo in
            let gridSize = min(geo.size.width, geo.size.height * 0.65) - 32
            let spacing: CGFloat = 8
            let gridPadding: CGFloat = 12
            let cellSize = (gridSize - gridPadding * 2 - spacing * 3) / 4

            VStack(spacing: 20) {
                Spacer()

                HStack(alignment: .top) {
                    Text("2048")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.47, green: 0.43, blue: 0.39))

                    Spacer()

                    HStack(spacing: 8) {
                        scorePill(title: "POÄNG", value: viewModel.score)
                        scorePill(title: "BÄST", value: viewModel.bestScore)
                    }
                }
                .padding(.horizontal, 16)

                Button {
                    withAnimation(.snappy) { viewModel.newGame() }
                } label: {
                    Text("Nytt spel")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.55, green: 0.47, blue: 0.40), in: RoundedRectangle(cornerRadius: 8))
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.47, green: 0.43, blue: 0.39))
                        .frame(width: gridSize, height: gridSize)

                    VStack(spacing: spacing) {
                        ForEach(0..<4, id: \.self) { row in
                            HStack(spacing: spacing) {
                                ForEach(0..<4, id: \.self) { col in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(red: 0.80, green: 0.76, blue: 0.71))
                                            .frame(width: cellSize, height: cellSize)

                                        if let val = viewModel.grid[row][col] {
                                            TileView(value: val, size: cellSize)
                                                .transition(.scale)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(gridPadding)
                }
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { gesture in
                            let dx = gesture.translation.width
                            let dy = gesture.translation.height

                            let direction: Direction
                            if abs(dx) > abs(dy) {
                                direction = dx > 0 ? .right : .left
                            } else {
                                direction = dy > 0 ? .down : .up
                            }

                            withAnimation(.snappy) {
                                viewModel.move(direction)
                            }
                        }
                )
                .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.score)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .alert("Grattis!", isPresented: $viewModel.showWinAlert) {
            Button("Fortsätt spela") {
                viewModel.gameStatus = .playing
            }
        } message: {
            Text("Du nådde 2048!")
        }
        .alert("Game Over!", isPresented: $viewModel.showLoseAlert) {
            Button("Nytt spel") {
                withAnimation(.snappy) { viewModel.newGame() }
            }
        } message: {
            Text("Poäng: \(viewModel.score)")
        }
    }

    private func scorePill(title: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
            Text("\(value)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(minWidth: 70)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(red: 0.55, green: 0.47, blue: 0.40), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    Game2048View()
}
