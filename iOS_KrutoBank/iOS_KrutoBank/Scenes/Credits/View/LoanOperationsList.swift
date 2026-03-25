import SwiftUI

struct LoanOperationsList: View {
    @ObservedObject private var themeManager = ThemeManager.shared

    let operations: [LoanOperation]
    let isLoading: Bool
    let errorText: String?
    let onRetry: () -> Void

    var body: some View {
        if isLoading {
            loadingView
        } else if let error = errorText {
            errorView(error, onRetry: onRetry)
        } else if operations.isEmpty {
            emptyView
        } else {
            operationsList
        }
    }
}

private extension LoanOperationsList {
    var isDark: Bool {
        themeManager.theme == .dark
    }

    var primaryTextColor: Color {
        isDark ? .white : Color.AppColor.textPrimary
    }

    var secondaryTextColor: Color {
        isDark ? Color.white.opacity(0.7) : Color.AppColor.textSecondary
    }

    var loadingView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            ProgressView()
                .tint(Color.AppColor.primaryPink)
            Text("Загрузка истории...")
                .font(.system(size: 14))
                .foregroundStyle(secondaryTextColor)
            Spacer(minLength: 40)
        }
    }

    func errorView(_ error: String, onRetry: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Color.AppColor.textError)

            Text(error)
                .font(.system(size: 14))
                .foregroundStyle(Color.AppColor.textError)

            Button("Повторить", action: onRetry)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.AppColor.primaryPink)

            Spacer(minLength: 40)
        }
    }

    var emptyView: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 40)

            Image(systemName: "clock.badge.xmark")
                .font(.system(size: 40))
                .foregroundStyle(secondaryTextColor.opacity(0.5))

            Text("История операций пуста")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(primaryTextColor)

            Text("Здесь будут отображаться все операции по кредиту")
                .font(.system(size: 13))
                .foregroundStyle(secondaryTextColor)
                .multilineTextAlignment(.center)

            Spacer(minLength: 40)
        }
    }

    var operationsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(operations) { operation in
                    LoanOperationRow(operation: operation)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}

struct LoanOperationRow: View {
    @ObservedObject private var themeManager = ThemeManager.shared

    let operation: LoanOperation

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(operation.iconColor.opacity(isDark ? 0.16 : 0.10))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: operation.iconName)
                        .font(.system(size: 16))
                        .foregroundStyle(operation.iconColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(operation.typeDisplayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(primaryTextColor)

                Text(operation.formattedDateTime)
                    .font(.system(size: 11))
                    .foregroundStyle(secondaryTextColor)
            }

            Spacer()

            Text(operation.formattedAmount)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(primaryTextColor)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

private extension LoanOperationRow {
    var isDark: Bool {
        themeManager.theme == .dark
    }

    var cardBackgroundColor: Color {
        isDark ? Color(.systemGray6).opacity(0.16) : Color.AppColor.primaryWhite
    }

    var primaryTextColor: Color {
        isDark ? .white : Color.AppColor.textPrimary
    }

    var secondaryTextColor: Color {
        isDark ? Color.white.opacity(0.7) : Color.AppColor.textSecondary
    }

    var borderColor: Color {
        operation.iconColor.opacity(isDark ? 0.28 : 0.2)
    }
}
