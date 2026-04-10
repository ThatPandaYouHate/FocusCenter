import SwiftUI

struct MinesweeperView: View {
    @State private var viewModel = MinesweeperViewModel()
    @State private var showWinAlert = false
    @State private var showLossAlert = false

    var body: some View {
        VStack(spacing: 12) {
            difficultyPicker
            statusBar
            gameGrid
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Nytt spel") {
                    viewModel.newGame()
                }
            }
        }
        .onChange(of: viewModel.gameStatus) { _, newValue in
            switch newValue {
            case .won: showWinAlert = true
            case .lost: showLossAlert = true
            case .playing: break
            }
        }
        .alert("Grattis!", isPresented: $showWinAlert) {
            Button("OK") { viewModel.newGame() }
        } message: {
            Text("Du klarade det på \(viewModel.timer) sekunder")
        }
        .alert("Game Over!", isPresented: $showLossAlert) {
            Button("OK") { viewModel.newGame() }
        } message: {
            Text("Du klickade på en mina")
        }
    }

    private var difficultyPicker: some View {
        Picker("Svårighetsgrad", selection: $viewModel.difficulty) {
            Text("Nybörjare").tag(MinesweeperDifficulty.beginner)
            Text("Medel").tag(MinesweeperDifficulty.intermediate)
            Text("Expert").tag(MinesweeperDifficulty.expert)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .onChange(of: viewModel.difficulty) { _, _ in
            viewModel.newGame()
        }
    }

    private var statusBar: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "bomb")
                Text("\(viewModel.flagsRemaining)")
                    .monospacedDigit()
            }

            Spacer()

            Button {
                viewModel.newGame()
            } label: {
                Text(smileyFace)
                    .font(.title)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "clock")
                Text("\(viewModel.timer)")
                    .monospacedDigit()
            }
        }
        .font(.title2.bold())
        .padding(.horizontal)
    }

    private var gameGrid: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 2
            let horizontalPadding: CGFloat = 16
            let availableWidth = geo.size.width - (horizontalPadding * 2)
            let totalSpacing = spacing * CGFloat(viewModel.difficulty.cols - 1)
            let cellSize = (availableWidth - totalSpacing) / CGFloat(viewModel.difficulty.cols)

            ScrollView {
                let columns = Array(
                    repeating: GridItem(.fixed(cellSize), spacing: spacing),
                    count: viewModel.difficulty.cols
                )

                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(viewModel.cells.flatMap { $0 }) { cell in
                        MinesweeperCellView(
                            cell: cell,
                            cellSize: cellSize,
                            gameStatus: viewModel.gameStatus
                        )
                        .onTapGesture {
                            withAnimation(.snappy) {
                                viewModel.revealCell(row: cell.row, col: cell.col)
                            }
                        }
                        .onLongPressGesture {
                            viewModel.toggleFlag(row: cell.row, col: cell.col)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }

    private var smileyFace: String {
        switch viewModel.gameStatus {
        case .playing: "🙂"
        case .won: "😎"
        case .lost: "😵"
        }
    }
}

#Preview {
    NavigationStack {
        MinesweeperView()
    }
}
