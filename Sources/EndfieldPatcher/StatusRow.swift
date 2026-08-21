import EndfieldCore
import SwiftUI

struct StatusRow: View {
    let title: String
    let state: CheckState

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .frame(width: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Text(badge)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    private var symbol: String {
        switch state {
        case .ready: "checkmark.circle.fill"
        case .checking: "clock"
        case .needsAttention: "exclamationmark.circle.fill"
        }
    }

    private var badge: String {
        switch state {
        case .ready: "Ready"
        case .checking: "Checking"
        case .needsAttention: "Needs attention"
        }
    }

    private var message: String {
        switch state {
        case .ready:
            "Everything needed here was found."
        case .checking:
            "Checking now."
        case .needsAttention(let message):
            message
        }
    }
}
