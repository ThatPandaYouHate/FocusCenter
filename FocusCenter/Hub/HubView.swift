import SwiftUI

struct HubView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(GameType.allCases) { game in
                        NavigationLink(value: game) {
                            GameCardView(game: game)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Focus Center")
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Välj en fokusaktivitet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}
