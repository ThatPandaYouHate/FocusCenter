import Foundation

struct SolitaireMove {
    let cards: [Card]
    let from: PileLocation
    let to: PileLocation
    let didFlipTableauCard: Bool
    let previousWaste: [Card]?
    let previousStock: [Card]?

    static func cardMove(
        cards: [Card],
        from: PileLocation,
        to: PileLocation,
        didFlip: Bool
    ) -> SolitaireMove {
        SolitaireMove(
            cards: cards,
            from: from,
            to: to,
            didFlipTableauCard: didFlip,
            previousWaste: nil,
            previousStock: nil
        )
    }

    static func drawMove(
        previousWaste: [Card],
        previousStock: [Card]
    ) -> SolitaireMove {
        SolitaireMove(
            cards: [],
            from: .stock,
            to: .waste,
            didFlipTableauCard: false,
            previousWaste: previousWaste,
            previousStock: previousStock
        )
    }
}
