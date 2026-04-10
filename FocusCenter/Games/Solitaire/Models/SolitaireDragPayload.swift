import CoreTransferable
import SwiftUI
import UniformTypeIdentifiers

enum SolitaireDragPayload: Codable, Hashable, Transferable {
    case tableau(column: Int, startIndex: Int)
    case waste
    case foundation(index: Int)

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

enum SolitaireDropDestination: Hashable {
    case tableau(Int)
    case foundation(Int)
    /// Registreras bara för geometri (källhög); giltig drop är aldrig waste.
    case waste
}

struct SolitaireDropZone: Equatable {
    let destination: SolitaireDropDestination
    let rect: CGRect
}

struct SolitaireDropZonesPreferenceKey: PreferenceKey {
    static var defaultValue: [SolitaireDropZone] = []

    static func reduce(value: inout [SolitaireDropZone], nextValue: () -> [SolitaireDropZone]) {
        value.append(contentsOf: nextValue())
    }
}

struct SolitaireDragState {
    let payload: SolitaireDragPayload
    let previewCards: [Card]
    var location: CGPoint
    let cardWidth: CGFloat
    /// Övre vänstra hörnet av första kortet i brädets koordinatsystem vid dragets start.
    let previewBaseOrigin: CGPoint
    let dragStartLocation: CGPoint

    var previewDisplayOrigin: CGPoint {
        CGPoint(
            x: previewBaseOrigin.x + (location.x - dragStartLocation.x),
            y: previewBaseOrigin.y + (location.y - dragStartLocation.y)
        )
    }
}

extension View {
    func solitaireDropZone(_ destination: SolitaireDropDestination) -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: SolitaireDropZonesPreferenceKey.self,
                    value: [SolitaireDropZone(
                        destination: destination,
                        rect: geo.frame(in: .named(SolitaireBoardLayout.coordinateSpaceName))
                    )]
                )
            }
        )
    }
}

enum SolitaireBoardLayout {
    static let coordinateSpaceName = "solitaireBoard"
}
