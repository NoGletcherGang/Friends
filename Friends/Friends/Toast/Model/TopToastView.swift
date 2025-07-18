import SwiftUI

extension View {
    
    func TopToastView(toast: Binding<Toast?>) -> some View {
        self.modifier(TopToastModifier(toast: toast))
    }
}
