import SwiftUI

struct LoanOperationsList: View {
    let operations: [LoanOperationResponse]
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
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            ProgressView()
                .tint(Color.AppColor.primaryPink)
            Text("Загрузка истории...")
                .font(.system(size: 14))
                .foregroundStyle(Color.AppColor.textSecondary)
            Spacer(minLength: 40)
        }
    }
    
    private func errorView(_ error: String, onRetry: @escaping () -> Void) -> some View {
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
    
    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 40)
            Image(systemName: "clock.badge.xmark")
                .font(.system(size: 40))
                .foregroundStyle(Color.AppColor.textSecondary.opacity(0.5))
            Text("История операций пуста")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.AppColor.textPrimary)
            Text("Здесь будут отображаться все операции по кредиту")
                .font(.system(size: 13))
                .foregroundStyle(Color.AppColor.textSecondary)
                .multilineTextAlignment(.center)
            Spacer(minLength: 40)
        }
    }
    
    private var operationsList: some View {
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
    let operation: LoanOperationResponse

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(operation.iconColor.opacity(0.1))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: operation.iconName)
                        .font(.system(size: 16))
                        .foregroundStyle(operation.iconColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(operation.typeDisplayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.AppColor.textPrimary)

                Text(operation.formattedDateTime)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.AppColor.textSecondary)
            }

            Spacer()

            Text(operation.formattedAmount)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.AppColor.textPrimary)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.AppColor.primaryWhite)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.AppColor.primaryPink.opacity(0.2), lineWidth: 1)
        )
    }
}
