import SwiftUI

struct BulletRuleView<Rule: View>: View {
    
    var isCompleted: Bool
    @ViewBuilder var rule: Rule

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                Circle()
                    .fill(isCompleted ? .green.opacity(0.15) : .gray.opacity(0.1))
                    .frame(width: 22, height: 22)
                
                Image(systemName: .completedRuleSystemImage)
                    .opacity(isCompleted ? 1 : 0)
                    .font(.caption)
                    .foregroundColor(isCompleted ? .green : .gray)
            }
            
            rule
                .foregroundStyle(isCompleted ? Color.primary : Color.gray)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.25), value: isCompleted)
    }
}

private extension String {
    static let completedRuleSystemImage = "checkmark"
}
