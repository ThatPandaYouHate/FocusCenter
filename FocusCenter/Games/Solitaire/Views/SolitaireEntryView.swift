import SwiftUI

/// Visar val av dra 1 / dra 3 innan patiensbrädet laddas (liknande Googles patiens).
struct SolitaireEntryView: View {
    @State private var selectedDraw: Int?

    var body: some View {
        Group {
            if let draw = selectedDraw {
                SolitaireView(initialDrawCount: draw) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        selectedDraw = nil
                    }
                }
            } else {
                SolitaireDifficultyView { draw in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        selectedDraw = draw
                    }
                }
            }
        }
    }
}

private struct SolitaireDifficultyView: View {
    let onSelectDraw: (Int) -> Void

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.35, blue: 0.15)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 24)

                VStack(spacing: 20) {
                    Text("Välj svårighetsgrad")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.black)

                    HStack(alignment: .top, spacing: 16) {
                        difficultyCard(
                            title: "LÄTT",
                            subtitle: "Dra 1",
                            draw: 1,
                            crownColor: Color(red: 0.85, green: 0.2, blue: 0.22)
                        )
                        difficultyCard(
                            title: "SVÅR",
                            subtitle: "Dra 3",
                            draw: 3,
                            crownColor: Color(red: 0.22, green: 0.28, blue: 0.45)
                        )
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.18), radius: 20, y: 10)
                )
                .padding(.horizontal, 28)

                Spacer(minLength: 24)
            }
        }
    }

    private func difficultyCard(title: String, subtitle: String, draw: Int, crownColor: Color) -> some View {
        Button {
            onSelectDraw(draw)
        } label: {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(crownColor.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(crownColor)
                }

                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.black)

                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
