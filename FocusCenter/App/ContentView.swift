import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HubView()
                .navigationDestination(for: GameType.self) { game in
                    game.destinationView
                        .navigationTitle(game.name)
                        .navigationBarTitleDisplayMode(.inline)
                }
        }
    }
}
