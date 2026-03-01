import SwiftUI

struct CommonButton: View {
    let title: String
    var style: CommonButtonStyle = .primary
    var isLoading: Bool = false
    var disabled: Bool = false
    var onTap: () -> Void

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.AppColor.primaryPink
        case .secondary:
            return Color.AppColor.primaryWhite
        case .text:
            return .clear
        case .danger:
            return Color.AppColor.textError
        }
    }

    private var textColor: Color {
        if disabled {
            return Color.AppColor.textSecondary
        }

        switch style {
        case .primary:
            return Color.AppColor.primaryWhite
        case .text:
            return Color.AppColor.textPrimary
        case .secondary:
            return Color.AppColor.primaryPink
        case .danger:
            return Color.AppColor.primaryWhite
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary:
            return Color.AppColor.primaryPink
        case .danger:
            return Color.AppColor.textError
        default:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .secondary, .danger: return 1
        default: return 0
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if isLoading {
                    ProgressView().tint(textColor)
                } else {
                    Text(title.localization)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(textColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(14)
        }
        .disabled(disabled || isLoading)
        .opacity(disabled ? 0.6 : 1)
    }
}
