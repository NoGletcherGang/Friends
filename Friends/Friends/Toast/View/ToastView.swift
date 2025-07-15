import SwiftUI

struct ToastView: View {
    
    var style: ToastStyle
    var message: String
    var width = CGFloat.infinity
    var onCancelTapped: (() -> Void)
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: style.iconFileName)
                .foregroundColor(style.themeColor)
            
            Text(message)
                .font(Font.caption)
                .foregroundColor(.primary)
            
            Spacer(minLength: 10)
            
            Button {
                onCancelTapped()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(style.themeColor)
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: width)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .secondary.opacity(0.25), radius: 4, x: 2, y: 2)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ToastView(style: .success, message: "SDFSDFDSf", onCancelTapped: { })
}
