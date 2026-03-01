import SwiftUI
import Combine

struct TabBar: View {
    @State
    private var selectedTabItem: TabBarItem

    private let onSelect: (TabBarItem) -> Void
    private let selectedTabItemPublisher: AnyPublisher<TabBarItem, Never>

    init(
        selectedTabItem: TabBarItem,
        selectedTabItemPublisher: AnyPublisher<TabBarItem, Never>,
        onSelect: @escaping (TabBarItem) -> Void
    ) {
        self.onSelect = onSelect
        self.selectedTabItemPublisher = selectedTabItemPublisher
        _selectedTabItem = State(initialValue: selectedTabItem)
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 6) {
                Rectangle()
                    .fill(Color.AppColor.primaryLight.opacity(0.35))
                    .frame(height: 1)

                HStack(spacing: 0) {
                    ForEach(TabBarItem.allCases, id: \.rawValue) { item in
                        tabItemView(item)
                    }
                }
                .padding(.bottom, bottomInset(from: proxy))
            }
            .background(Color.AppColor.primaryWhite)
            .onReceive(selectedTabItemPublisher) { selectedTabItem = $0 }
        }
        .frame(height: 64)
    }
}

private extension TabBar {
    func bottomInset(from proxy: GeometryProxy) -> CGFloat {
        let inset = proxy.safeAreaInsets.bottom
        return inset > 0 ? inset : 6
    }

    @ViewBuilder
    func tabItemView(_ item: TabBarItem) -> some View {
        let isSelected = (item == selectedTabItem)
        let iconColor: Color = isSelected ? .AppColor.primaryPink : .AppColor.textSecondary
        let textColor: Color = isSelected ? .AppColor.primaryPink : .AppColor.textSecondary

        Button {
            onSelect(item)
        } label: {
            VStack(spacing: 3) {
                item.icon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(iconColor)
                    .frame(width: 24, height: 24)

                Text(item.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(textColor)
            }
            .frame(height: 42)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
