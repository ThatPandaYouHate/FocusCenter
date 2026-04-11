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
            }
            .id(viewModel.gameID)
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
                    viewModel.newGame(newSize: newSize)
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
        let gridCols = CGFloat(viewModel.playerGrid.first?.count ?? 1)
        let totalColumns = rowClueColumns + gridCols
        return min(availableWidth / totalColumns, 40)
    }

    // MARK: - Column Clues

    private func columnCluesSection(cellSize cs: CGFloat) -> some View {
        let clues = viewModel.puzzle.colClues
        let maxCount = viewModel.maxColClueCount
        return HStack(spacing: 0) {
            ForEach(Array(clues.enumerated()), id: \.offset) { _, colClue in
                let padded = padClues(colClue, toCount: maxCount)
                NonogramClueView(clues: padded, orientation: .vertical, cellSize: cs)
                    .frame(width: cs)
            }
        }
    }

    // MARK: - Row Clues

    private func rowCluesSection(cellSize cs: CGFloat) -> some View {
        let clues = viewModel.puzzle.rowClues
        let maxCount = viewModel.maxRowClueCount
        return VStack(spacing: 0) {
            ForEach(Array(clues.enumerated()), id: \.offset) { _, rowClue in
                let padded = padClues(rowClue, toCount: maxCount)
                NonogramClueView(clues: padded, orientation: .horizontal, cellSize: cs)
                    .frame(height: cs)
            }
        }
    }

    private func padClues(_ clues: [Int], toCount maxCount: Int) -> [Int] {
        if clues.count < maxCount {
            return Array(repeating: -1, count: maxCount - clues.count) + clues
        }
        return clues
    }

    // MARK: - Grid

    private func gridSection(cellSize cs: CGFloat) -> some View {
        let snapshot = NonogramGridSnapshot(viewModel: viewModel)

        return VStack(spacing: 0) {
            ForEach(snapshot.rows, id: \.rowIndex) { rowData in
                HStack(spacing: 0) {
                    ForEach(rowData.cells, id: \.colIndex) { cell in
                        NonogramGridCellView(
                            state: cell.state,
                            size: cs,
                            isCorrectlyFilled: cell.isCorrectlyFilled
                        )
                        .onTapGesture {
                            viewModel.toggleCell(row: cell.rowIndex, col: cell.colIndex)
                            viewModel.checkWin()
                        }
                        .overlay(alignment: .trailing) {
                            if cell.colIndex < rowData.cells.count - 1 && (cell.colIndex + 1) % 5 == 0 {
                                Rectangle()
                                    .fill(Color.primary.opacity(0.4))
                                    .frame(width: 1.5)
                            }
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    if rowData.rowIndex < snapshot.rows.count - 1 && (rowData.rowIndex + 1) % 5 == 0 {
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

// MARK: - Grid Snapshot (value types – safe from @Observable races)

private struct NonogramGridSnapshot {
    let rows: [RowData]

    struct RowData: Identifiable {
        let rowIndex: Int
        let cells: [CellData]
        var id: Int { rowIndex }
    }

    struct CellData: Identifiable {
        let rowIndex: Int
        let colIndex: Int
        let state: NonogramCellState
        let isCorrectlyFilled: Bool
        var id: Int { colIndex }
    }

    init(viewModel: NonogramViewModel) {
        let grid = viewModel.playerGrid
        let solution = viewModel.puzzle.solution
        let isWon = viewModel.isGameWon

        rows = grid.indices.map { r in
            let rowCells = grid[r]
            let solutionRow = r < solution.count ? solution[r] : []
            return RowData(
                rowIndex: r,
                cells: rowCells.indices.map { c in
                    CellData(
                        rowIndex: r,
                        colIndex: c,
                        state: rowCells[c],
                        isCorrectlyFilled: isWon && c < solutionRow.count && solutionRow[c]
                    )
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        NonogramView()
    }
}
