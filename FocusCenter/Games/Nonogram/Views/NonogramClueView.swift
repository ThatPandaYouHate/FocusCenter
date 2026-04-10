import SwiftUI

struct NonogramClueView: View {
    let clues: [Int]
    let orientation: Axis
    let cellSize: CGFloat

    var body: some View {
        let layout = orientation == .horizontal
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(VStackLayout(spacing: 0))

        layout {
            ForEach(Array(clues.enumerated()), id: \.offset) { _, clue in
                if clue >= 0 {
                    Text("\(clue)")
                        .font(.system(size: cellSize * 0.45, weight: .medium))
                        .frame(width: cellSize, height: cellSize)
                        .monospacedDigit()
                } else {
                    Color.clear
                        .frame(width: cellSize, height: cellSize)
                }
            }
        }
    }
}
