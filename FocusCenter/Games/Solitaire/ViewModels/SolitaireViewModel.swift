import SwiftUI

@Observable
class SolitaireViewModel {
    var tableau: [[Card]] = Array(repeating: [], count: 7)
    var foundations: [[Card]] = Array(repeating: [], count: 4)
    var stock: [Card] = []
    var waste: [Card] = []
    var drawCount: Int = 3
    var selection: CardSelection?
    var showWin: Bool = false
    var dropZones: [SolitaireDropZone] = []
    var hoveredDrop: SolitaireDropDestination?
    var activeDrag: SolitaireDragState?
    private var undoStack: [SolitaireMove] = []

    var isGameWon: Bool {
        foundations.allSatisfy { $0.count == 13 }
    }

    var canUndo: Bool { !undoStack.isEmpty }

    init() {
        newGame()
    }

    // MARK: - New Game

    func newGame() {
        var deck = Card.fullDeck().shuffled()
        tableau = Array(repeating: [], count: 7)
        foundations = Array(repeating: [], count: 4)
        waste = []
        undoStack = []
        selection = nil
        showWin = false
        cancelActiveDrag()
        dropZones = []

        for col in 0..<7 {
            for row in 0...col {
                var card = deck.removeFirst()
                card.isFaceUp = (row == col)
                tableau[col].append(card)
            }
        }

        stock = deck
    }

    // MARK: - Draw from Stock

    func drawFromStock() {
        let prevWaste = waste
        let prevStock = stock

        if stock.isEmpty {
            stock = waste.reversed().map { card in
                var c = card
                c.isFaceUp = false
                return c
            }
            waste = []
        } else {
            let count = min(drawCount, stock.count)
            let drawn = stock.suffix(count)
            stock.removeLast(count)
            waste.append(contentsOf: drawn.reversed().map { card in
                var c = card
                c.isFaceUp = true
                return c
            })
        }

        selection = nil
        undoStack.append(.drawMove(previousWaste: prevWaste, previousStock: prevStock))
    }

    // MARK: - Tap Handling

    func handleTap(location: PileLocation, cardIndex: Int?) {
        if location == .stock {
            drawFromStock()
            return
        }

        if let currentSelection = selection {
            if let cardIndex,
               currentSelection.source == location,
               currentSelection.cardIndex == cardIndex {
                selection = nil
                return
            }
            if tryMove(from: currentSelection.source, cardIndex: currentSelection.cardIndex, to: location) {
                selection = nil
                checkWin()
                return
            }
        }

        guard let cardIndex else {
            if selection != nil {
                if case .tableau = location {
                    if tryMove(from: selection!.source, cardIndex: selection!.cardIndex, to: location) {
                        selection = nil
                        checkWin()
                        return
                    }
                }
                selection = nil
            }
            return
        }

        switch location {
        case .tableau(let col):
            guard col < tableau.count,
                  cardIndex < tableau[col].count,
                  tableau[col][cardIndex].isFaceUp else { return }
            selection = CardSelection(source: location, cardIndex: cardIndex)
        case .waste:
            guard !waste.isEmpty else { return }
            selection = CardSelection(source: .waste, cardIndex: waste.count - 1)
        case .foundation(let idx):
            guard !foundations[idx].isEmpty else { return }
            selection = CardSelection(source: location, cardIndex: foundations[idx].count - 1)
        case .stock:
            break
        }
    }

    func setDropZones(_ zones: [SolitaireDropZone]) {
        dropZones = zones
    }

    private func hitTestDrop(at point: CGPoint) -> SolitaireDropDestination? {
        let hits = dropZones.filter { $0.rect.contains(point) && $0.destination != .waste }
        return hits.min(by: {
            $0.rect.width * $0.rect.height < $1.rect.width * $1.rect.height
        })?.destination
    }

    private func tableauCardYOffset(column: Int, cardIndex: Int) -> CGFloat {
        let faceDownOffset: CGFloat = 8
        let faceUpOffset: CGFloat = 20
        guard column < tableau.count, cardIndex <= tableau[column].count else { return 0 }
        let cards = tableau[column]
        var offset: CGFloat = 0
        for i in 0..<min(cardIndex, cards.count) {
            offset += cards[i].isFaceUp ? faceUpOffset : faceDownOffset
        }
        return offset
    }

    func beginTableauDrag(
        column: Int,
        startIndex: Int,
        cardWidth: CGFloat,
        dragStartLocation: CGPoint
    ) {
        guard activeDrag == nil,
              column < tableau.count,
              startIndex < tableau[column].count,
              tableau[column][startIndex].isFaceUp else { return }
        let moving = Array(tableau[column][startIndex...])
        guard moving.allSatisfy(\.isFaceUp) else { return }
        selection = nil
        let pileRect = dropZones.first { $0.destination == .tableau(column) }?.rect ?? .zero
        let yCard = tableauCardYOffset(column: column, cardIndex: startIndex)
        let base = CGPoint(x: pileRect.minX, y: pileRect.minY + yCard)
        activeDrag = SolitaireDragState(
            payload: .tableau(column: column, startIndex: startIndex),
            previewCards: moving,
            location: dragStartLocation,
            cardWidth: cardWidth,
            previewBaseOrigin: base,
            dragStartLocation: dragStartLocation
        )
        hoveredDrop = hitTestDrop(at: dragStartLocation)
    }

    /// Antal synliga kort i waste (fläkt), som i klassisk draw-1 / draw-3-klient.
    func wasteVisibleFanCount() -> Int {
        guard !waste.isEmpty else { return 0 }
        return min(waste.count, drawCount, 3)
    }

    func wasteFanStagger(cardWidth: CGFloat) -> CGFloat {
        max(12, cardWidth * 0.2)
    }

    func wastePileDisplayWidth(cardWidth: CGFloat) -> CGFloat {
        let n = wasteVisibleFanCount()
        let stagger = wasteFanStagger(cardWidth: cardWidth)
        if n <= 0 { return cardWidth }
        return cardWidth + CGFloat(n - 1) * stagger
    }

    func beginWasteDrag(cardWidth: CGFloat, dragStartLocation: CGPoint) {
        guard activeDrag == nil, waste.last != nil else { return }
        selection = nil
        let rect = dropZones.first { $0.destination == .waste }?.rect ?? .zero
        let stagger = wasteFanStagger(cardWidth: cardWidth)
        let visible = wasteVisibleFanCount()
        let topOffsetX = CGFloat(max(0, visible - 1)) * stagger
        let base = CGPoint(x: rect.minX + topOffsetX, y: rect.minY)
        activeDrag = SolitaireDragState(
            payload: .waste,
            previewCards: [waste.last!],
            location: dragStartLocation,
            cardWidth: cardWidth,
            previewBaseOrigin: base,
            dragStartLocation: dragStartLocation
        )
        hoveredDrop = hitTestDrop(at: dragStartLocation)
    }

    func beginFoundationDrag(foundationIndex: Int, cardWidth: CGFloat, dragStartLocation: CGPoint) {
        guard activeDrag == nil,
              foundationIndex < foundations.count,
              let last = foundations[foundationIndex].last else { return }
        selection = nil
        let rect = dropZones.first { $0.destination == .foundation(foundationIndex) }?.rect ?? .zero
        let base = CGPoint(x: rect.minX, y: rect.minY)
        activeDrag = SolitaireDragState(
            payload: .foundation(index: foundationIndex),
            previewCards: [last],
            location: dragStartLocation,
            cardWidth: cardWidth,
            previewBaseOrigin: base,
            dragStartLocation: dragStartLocation
        )
        hoveredDrop = hitTestDrop(at: dragStartLocation)
    }

    func updateDrag(location: CGPoint) {
        guard var drag = activeDrag else { return }
        drag.location = location
        activeDrag = drag
        hoveredDrop = hitTestDrop(at: location)
    }

    func commitDrag(at location: CGPoint) {
        guard let drag = activeDrag else { return }
        let dest = hitTestDrop(at: location)
        activeDrag = nil
        hoveredDrop = nil
        guard let dest else { return }
        withAnimation(.snappy) {
            _ = performDrop(drag.payload, onto: dest)
        }
    }

    func cancelActiveDrag() {
        activeDrag = nil
        hoveredDrop = nil
    }

    func tableauDragOpacity(column: Int, cardIndex: Int) -> Double {
        guard let drag = activeDrag,
              case .tableau(let col, let start) = drag.payload,
              col == column,
              cardIndex >= start else { return 1 }
        return 0.38
    }

    func wasteDragOpacity() -> Double {
        activeDrag?.payload == .waste ? 0.38 : 1
    }

    func foundationDragOpacity(foundationIndex: Int) -> Double {
        guard case .foundation(let idx)? = activeDrag?.payload, idx == foundationIndex else { return 1 }
        return 0.38
    }

    @discardableResult
    func performDrop(_ payload: SolitaireDragPayload, onto destination: SolitaireDropDestination) -> Bool {
        selection = nil
        if destination == .waste { return false }
        let ok: Bool
        switch (payload, destination) {
        case let (.tableau(fromCol, index), .tableau(toCol)):
            ok = moveTableauToTableau(fromCol: fromCol, cardIndex: index, toCol: toCol)
        case (.waste, .tableau(let toCol)):
            ok = moveWasteToTableau(toCol: toCol)
        case let (.foundation(fromFdn), .tableau(toCol)):
            ok = moveFoundationToTableau(fromFdn: fromFdn, toCol: toCol)
        case let (.tableau(fromCol, index), .foundation(toFdn)):
            guard fromCol < tableau.count,
                  index == tableau[fromCol].count - 1 else { return false }
            ok = moveToFoundation(
                card: tableau[fromCol].last,
                from: .tableau(fromCol),
                foundationIndex: toFdn
            )
        case (.waste, .foundation(let toFdn)):
            ok = moveToFoundation(card: waste.last, from: .waste, foundationIndex: toFdn)
        default:
            ok = false
        }
        if ok { checkWin() }
        return ok
    }

    func handleDoubleTap(location: PileLocation, cardIndex: Int?) {
        guard let cardIndex else { return }
        let card: Card?

        switch location {
        case .tableau(let col):
            guard col < tableau.count, cardIndex == tableau[col].count - 1 else { return }
            card = tableau[col].last
        case .waste:
            card = waste.last
        default:
            return
        }

        guard let card else { return }

        for i in 0..<4 {
            if card.canStackOnFoundation(foundations[i], foundationIndex: i) {
                _ = tryMove(from: location, cardIndex: cardIndex, to: .foundation(i))
                selection = nil
                checkWin()
                return
            }
        }
    }

    // MARK: - Move Logic

    private func tryMove(from source: PileLocation, cardIndex: Int, to destination: PileLocation) -> Bool {
        switch (source, destination) {
        case (.tableau(let fromCol), .tableau(let toCol)):
            return moveTableauToTableau(fromCol: fromCol, cardIndex: cardIndex, toCol: toCol)
        case (.tableau(let fromCol), .foundation(let toFdn)):
            return moveToFoundation(card: tableau[fromCol].last, from: source, foundationIndex: toFdn)
        case (.waste, .tableau(let toCol)):
            return moveWasteToTableau(toCol: toCol)
        case (.waste, .foundation(let toFdn)):
            return moveToFoundation(card: waste.last, from: .waste, foundationIndex: toFdn)
        case (.foundation(let fromFdn), .tableau(let toCol)):
            return moveFoundationToTableau(fromFdn: fromFdn, toCol: toCol)
        default:
            return false
        }
    }

    private func moveTableauToTableau(fromCol: Int, cardIndex: Int, toCol: Int) -> Bool {
        guard fromCol != toCol,
              fromCol < tableau.count,
              toCol < tableau.count,
              cardIndex < tableau[fromCol].count else { return false }

        let movingCards = Array(tableau[fromCol][cardIndex...])
        guard let firstCard = movingCards.first else { return false }

        let targetCard = tableau[toCol].last
        guard firstCard.canStackOnTableau(targetCard) else { return false }

        tableau[fromCol].removeSubrange(cardIndex...)
        tableau[toCol].append(contentsOf: movingCards)

        let didFlip = flipAfterRemoval(fromCol: fromCol)
        if didFlip {
            tableau[fromCol][tableau[fromCol].count - 1].isFaceUp = true
        }

        undoStack.append(.cardMove(cards: movingCards, from: .tableau(fromCol), to: .tableau(toCol), didFlip: didFlip))
        return true
    }

    private func moveToFoundation(card: Card?, from source: PileLocation, foundationIndex: Int) -> Bool {
        guard let card, card.canStackOnFoundation(foundations[foundationIndex], foundationIndex: foundationIndex) else { return false }

        var didFlip = false
        switch source {
        case .tableau(let col):
            tableau[col].removeLast()
            didFlip = flipAfterRemoval(fromCol: col)
            if didFlip {
                tableau[col][tableau[col].count - 1].isFaceUp = true
            }
        case .waste:
            waste.removeLast()
        default:
            return false
        }

        foundations[foundationIndex].append(card)
        undoStack.append(.cardMove(cards: [card], from: source, to: .foundation(foundationIndex), didFlip: didFlip))
        return true
    }

    private func moveWasteToTableau(toCol: Int) -> Bool {
        guard let card = waste.last else { return false }
        let targetCard = tableau[toCol].last
        guard card.canStackOnTableau(targetCard) else { return false }

        waste.removeLast()
        tableau[toCol].append(card)
        undoStack.append(.cardMove(cards: [card], from: .waste, to: .tableau(toCol), didFlip: false))
        return true
    }

    private func moveFoundationToTableau(fromFdn: Int, toCol: Int) -> Bool {
        guard let card = foundations[fromFdn].last else { return false }
        let targetCard = tableau[toCol].last
        guard card.canStackOnTableau(targetCard) else { return false }

        foundations[fromFdn].removeLast()
        tableau[toCol].append(card)
        undoStack.append(.cardMove(cards: [card], from: .foundation(fromFdn), to: .tableau(toCol), didFlip: false))
        return true
    }

    private func flipAfterRemoval(fromCol: Int) -> Bool {
        if let last = tableau[fromCol].last, !last.isFaceUp {
            return true
        }
        return false
    }

    // MARK: - Undo

    func undo() {
        guard let move = undoStack.popLast() else { return }
        selection = nil
        cancelActiveDrag()

        if let prevWaste = move.previousWaste, let prevStock = move.previousStock {
            waste = prevWaste
            stock = prevStock
            return
        }

        switch move.to {
        case .tableau(let toCol):
            let count = move.cards.count
            tableau[toCol].removeLast(count)
        case .foundation(let idx):
            foundations[idx].removeLast()
        default:
            break
        }

        if move.didFlipTableauCard {
            if case .tableau(let fromCol) = move.from {
                if !tableau[fromCol].isEmpty {
                    tableau[fromCol][tableau[fromCol].count - 1].isFaceUp = false
                }
            }
        }

        switch move.from {
        case .tableau(let fromCol):
            tableau[fromCol].append(contentsOf: move.cards)
        case .waste:
            waste.append(contentsOf: move.cards)
        case .foundation(let idx):
            foundations[idx].append(contentsOf: move.cards)
        default:
            break
        }
    }

    // MARK: - Win

    private func checkWin() {
        if isGameWon {
            showWin = true
        }
    }

    // MARK: - Helpers

    func isSelected(location: PileLocation, cardIndex: Int) -> Bool {
        guard let sel = selection else { return false }
        if sel.source == location {
            switch location {
            case .tableau:
                return cardIndex >= sel.cardIndex
            default:
                return cardIndex == sel.cardIndex
            }
        }
        return false
    }
}
