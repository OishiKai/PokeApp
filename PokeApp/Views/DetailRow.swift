import SwiftUI

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(uiColor: .secondaryLabel))
            Spacer()
            Text(value)
                .foregroundColor(Color(uiColor: .label))
        }
        .padding(.horizontal)
    }
} 