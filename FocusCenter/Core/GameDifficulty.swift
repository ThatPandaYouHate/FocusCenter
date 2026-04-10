import SwiftUI

enum GameDifficulty: String, CaseIterable {
    case low
    case medium
    case high

    var label: String {
        switch self {
        case .low: "Enkel"
        case .medium: "Medel"
        case .high: "Svår"
        }
    }

    var color: Color {
        switch self {
        case .low: .green
        case .medium: .orange
        case .high: .red
        }
    }
}
