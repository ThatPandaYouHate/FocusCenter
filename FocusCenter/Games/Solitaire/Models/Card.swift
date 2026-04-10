import Foundation

enum Suit: Int, CaseIterable, Comparable {
    case hearts, diamonds, clubs, spades

    static func < (lhs: Suit, rhs: Suit) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var symbol: String {
        switch self {
        case .hearts: "♥"
        case .diamonds: "♦"
        case .clubs: "♣"
        case .spades: "♠"
        }
    }

    var color: CardColor {
        switch self {
        case .hearts, .diamonds: .red
        case .clubs, .spades: .black
        }
    }
}

enum CardColor {
    case red, black

    var opposite: CardColor {
        self == .red ? .black : .red
    }
}

enum Rank: Int, CaseIterable, Comparable {
    case ace = 1
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king

    static func < (lhs: Rank, rhs: Rank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .ace: "A"
        case .two: "2"
        case .three: "3"
        case .four: "4"
        case .five: "5"
        case .six: "6"
        case .seven: "7"
        case .eight: "8"
        case .nine: "9"
        case .ten: "10"
        case .jack: "J"
        case .queen: "Q"
        case .king: "K"
        }
    }
}

struct Card: Identifiable, Equatable {
    let id: UUID
    let suit: Suit
    let rank: Rank
    var isFaceUp: Bool

    init(suit: Suit, rank: Rank, isFaceUp: Bool = false) {
        self.id = UUID()
        self.suit = suit
        self.rank = rank
        self.isFaceUp = isFaceUp
    }

    var color: CardColor { suit.color }

    static func fullDeck() -> [Card] {
        var deck: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(suit: suit, rank: rank))
            }
        }
        return deck
    }

    func canStackOnTableau(_ other: Card?) -> Bool {
        guard let other else {
            return rank == .king
        }
        return other.isFaceUp
            && color != other.color
            && rank.rawValue == other.rank.rawValue - 1
    }

    func canStackOnFoundation(_ pile: [Card], foundationIndex: Int) -> Bool {
        guard foundationIndex >= 0, foundationIndex < Suit.allCases.count else { return false }
        let expectedSuit = Suit.allCases[foundationIndex]

        if pile.isEmpty {
            return rank == .ace && suit == expectedSuit
        }
        guard let top = pile.last else { return false }
        return suit == top.suit && suit == expectedSuit && rank.rawValue == top.rank.rawValue + 1
    }
}

enum PileLocation: Equatable, Hashable {
    case tableau(Int)
    case foundation(Int)
    case waste
    case stock
}

struct CardSelection: Equatable {
    let source: PileLocation
    let cardIndex: Int
}
