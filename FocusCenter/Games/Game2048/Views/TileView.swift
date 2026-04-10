import SwiftUI

struct TileView: View {
    let value: Int
    let size: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(backgroundColor)
            .frame(width: size, height: size)
            .overlay(
                Text("\(value)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(textColor)
            )
    }

    private var fontSize: CGFloat {
        if value >= 1000 { return size * 0.28 }
        if value >= 100 { return size * 0.35 }
        return size * 0.42
    }

    private var textColor: Color {
        value <= 4 ? Color(red: 0.47, green: 0.43, blue: 0.40) : .white
    }

    private var backgroundColor: Color {
        switch value {
        case 2:    return Color(red: 238/255, green: 228/255, blue: 218/255)
        case 4:    return Color(red: 237/255, green: 224/255, blue: 200/255)
        case 8:    return Color(red: 242/255, green: 177/255, blue: 121/255)
        case 16:   return Color(red: 245/255, green: 149/255, blue: 99/255)
        case 32:   return Color(red: 246/255, green: 124/255, blue: 95/255)
        case 64:   return Color(red: 246/255, green: 94/255, blue: 59/255)
        case 128:  return Color(red: 237/255, green: 207/255, blue: 114/255)
        case 256:  return Color(red: 237/255, green: 204/255, blue: 97/255)
        case 512:  return Color(red: 237/255, green: 200/255, blue: 80/255)
        case 1024: return Color(red: 237/255, green: 197/255, blue: 63/255)
        case 2048: return Color(red: 237/255, green: 194/255, blue: 46/255)
        default:   return Color(red: 60/255, green: 58/255, blue: 50/255)
        }
    }
}
