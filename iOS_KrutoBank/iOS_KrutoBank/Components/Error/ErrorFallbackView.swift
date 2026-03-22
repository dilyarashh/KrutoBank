import SwiftUI

/// Full-screen fallback view for fatal or unrecoverable errors
struct ErrorFallbackView: View {
    let error: AppError
    var onRetry: (() -> Void)?
    var onLogout: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.AppColor.textError)

            VStack(spacing: 8) {
                Text("Что-то пошло не так")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.AppColor.textPrimary)

                Text(error.errorDescription ?? "Неизвестная ошибка")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 12) {
                if let onRetry = onRetry {
                    CommonButton(title: "Повторить", style: .primary) {
                        onRetry()
                    }
                }

                if error.isFatal, let onLogout = onLogout {
                    CommonButton(title: "Войти снова", style: .secondary) {
                        onLogout()
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .background(Color.AppColor.backgroundMain.ignoresSafeArea())
    }
}
