import SwiftUI

struct NonogramView: View {
    @State private var viewModel = NonogramViewModel()

    var body: some View {
        GeometryReader { geo in
            let cs = cellSize(for: geo)
            let rowClueWidth = CGFloat(viewModel.maxRowClueCount) * cs
            let colClueHeight = CGFloat(viewModel.maxColClueCount) * cs

            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Color.clear
                            .frame(width: rowClueWidth, height: colClueHeight)

                        columnCluesSection(cellSize: cs)
                    }

                    HStack(spacing: 0) {
                        rowCluesSection(cellSize: cs)

                        gridSection(cellSize: cs)
                    }
                }
                .padding(4)
                .id(viewModel.size)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Nonogram")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Nytt pussel") {
                    viewModel.newGame()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            controlsBar
                .background(.ultraThinMaterial)
        }
        .alert("Grattis! Du löste pusslet!", isPresented: $viewModel.showWinAlert) {
            Button("Nytt pussel") { viewModel.newGame() }
            Button("OK", role: .cancel) { }
        }
    }

    // MARK: - Controls

    private var controlsBar: some View {
        VStack(spacing: 12) {
            Picker("Storlek", selection: Binding(
                get: { viewModel.size },
                set: { newSize in
                    viewModel.size = newSize
                    viewModel.newGame()
                }
            )) {
                ForEach(NonogramSize.allCases, id: \.self) { s in
                    Text(s.label).tag(s)
                }
            }
            .pickerStyle(.segmented)

            Picker("Läge", selection: $viewModel.isFillingMode) {
                Label("Fylla", systemImage: "square.fill").tag(true)
                Label("Kryss", systemImage: "xmark").tag(false)
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Cell Size

    private func cellSize(for geo: GeometryProxy) -> CGFloat {
        let availableWidth = geo.size.width - 8
        let rowClueColumns = CGFloat(viewModel.maxRowClueCount)
        let totalColumns = rowClueColumns + CGFloat(viewModel.puzzle.colClues.count)
        return min(availableWidth / totalColumns, 40)
    }

    // MARK: - Column Clues

    private func columnCluesSection(cellSize cs: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(viewModel.puzzle.colClues.indices, id: \.self) { col in
                let padded = paddedColClues(viewModel.puzzle.colClues[col])
                NonogramClueView(clues: padded, orientation: .vertical, cellSize: cs)
                    .frame(width: cs)
            }
        }
    }

    private func paddedColClues(_ clues: [Int]) -> [Int] {
        let max = viewModel.maxColClueCount
        if clues.count < max {
            return Array(repeating: -1, count: max - clues.count) + clues
        }
        return clues
    }

    // MARK: - Row Clues

    private func rowCluesSection(cellSize cs: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(viewModel.puzzle.rowClues.indices, id: \.self) { row in
                let padded = paddedRowClues(viewModel.puzzle.rowClues[row])
                NonogramClueView(clues: padded, orientation: .horizontal, cellSize: cs)
                    .frame(height: cs)
            }
        }
    }

    private func paddedRowClues(_ clues: [Int]) -> [Int] {
        let max = viewModel.maxRowClueCount
        if clues.count < max {
            return Array(repeating: -1, count: max - clues.count) + clues
        }
        return clues
    }

    // MARK: - Grid

    private func gridSection(cellSize cs: CGFloat) -> some View {
        let rows = viewModel.playerGrid.count
        let cols = viewModel.playerGrid.first?.count ?? 0

        return VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<cols, id: \.self) { col in
                        NonogramGridCellView(
                            state: viewModel.playerGrid[row][col],
                            size: cs,
                            isCorrectlyFilled: viewModel.isGameWon && viewModel.puzzle.solution[row][col]
                        )
                        .animation(.snappy, value: viewModel.playerGrid[row][col])
                        .onTapGesture {
                            viewModel.toggleCell(row: row, col: col)
                            viewModel.checkWin()
                        }
                        .overlay(alignment: .trailing) {
                            if col < cols - 1 && (col + 1) % 5 == 0 {
                                Rectangle()
                                    .fill(Color.primary.opacity(0.4))
                                    .frame(width: 1.5)
                            }
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    if row < rows - 1 && (row + 1) % 5 == 0 {
                        Rectangle()
                            .fill(Color.primary.opacity(0.4))
                            .frame(height: 1.5)
                    }
                }
            }
        }
        .border(Color.primary.opacity(0.5), width: 1)
    }
}

#Preview {
    NavigationStack {
        NonogramView()
    }
}
