import SwiftUI

struct CardView: View {
    let card: Card?
    let width: CGFloat
    var isSelected: Bool = false
    var isPlaceholder: Bool = false

    private var height: CGFloat { width * 1.4 }

    var body: some View {
        if let card {
            if card.isFaceUp {
                faceUpCard(card)
            } else {
                cardBack
            }
        } else if isPlaceholder {
            placeholder
        }
    }

    private func faceUpCard(_ card: Card) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: width * 0.1)
                .fill(Color.white)
            RoundedRectangle(cornerRadius: width * 0.1)
                .strokeBorder(isSelected ? Color.yellow : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 0.5)

            VStack(spacing: 0) {
                HStack {
                    VStack(spacing: -2) {
                        Text(card.rank.displayName)
                            .font(.system(size: width * 0.28, weight: .bold, design: .rounded))
                        Text(card.suit.symbol)
                            .font(.system(size: width * 0.22))
                    }
                    .foregroundStyle(card.color == .red ? Color.red : Color.black)
                    Spacer()
                }
                .padding(.leading, width * 0.08)
                .padding(.top, width * 0.06)

                Spacer()

                Text(card.suit.symbol)
                    .font(.system(size: width * 0.45))
                    .foregroundStyle(card.color == .red ? Color.red : Color.black)
                    .opacity(0.4)

                Spacer()
            }
        }
        .frame(width: width, height: height)
        .shadow(color: isSelected ? .yellow.opacity(0.4) : .black.opacity(0.15), radius: isSelected ? 4 : 2)
    }

    private var cardBack: some View {
        ZStack {
            RoundedRectangle(cornerRadius: width * 0.1)
                .fill(Color.blue.opacity(0.8))
            RoundedRectangle(cornerRadius: width * 0.1 - 3)
                .fill(Color.blue.opacity(0.6))
                .padding(3)
            RoundedRectangle(cornerRadius: width * 0.1 - 5)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                .padding(5)
        }
        .frame(width: width, height: height)
        .shadow(color: .black.opacity(0.15), radius: 2)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: width * 0.1)
            .strokeBorder(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
            .frame(width: width, height: height)
    }
}
