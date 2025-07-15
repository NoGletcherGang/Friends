import SwiftUI

// TODO: Doc

enum RegistrationSteps: Int {
    case begin
    case middle
    case end
    case loadingForRegistration
}

struct RegistrationView: View {
    
    @State private var currentStep: RegistrationSteps = .end
    @State private var onboardingHeight: CGFloat = 50
    @State private var email: String = ""
    
    var body: some View {
        let RegistrationView = CurrentRegistrationView(
            registrationStep: $currentStep,
            email: $email
        )
        NavigationStack {
            RegistrationView
                .padding(.top, currentStep == .begin ? .onboardingOverlayHeight : 0)
            
            Spacer()
        }
        .safeAreaInset(edge: .top) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: .onboardingOverlayRadius)
                    .fill(Color(uiColor: .systemGray6))
                    .frame(maxWidth: .infinity)
                    .frame(height: .onboardingOverlayHeight)
                    .ignoresSafeArea()
                
                RegistrationOnboardingView()
                    .frame(maxWidth: .infinity)
                    .frame(height: onboardingHeight)
                    .clipShape(
                        RoundedRectangle(cornerRadius: .onboardingOverlayRadius)
                    )
                    .padding(.bottom, .onboardingOverlayHeight / 2)
            }
            .opacity(currentStep == .begin ? 1 : 0)
        }
        .overlay(alignment: .bottom) {
            RegistrationStepsView(
                emailValidator: RegistrationView.validator,
                currentStep: $currentStep
            )
        }
    }
    
    private struct RegistrationStepsView: View {
        
        var emailValidator: IEmailValidator
        @Binding var currentStep: RegistrationSteps
        @Namespace private var loadingIndicator
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VStack() {
                IndicatorView(currentStep: currentStep)
                    .padding(.bottom)
                
                HStack {
                    if currentStep.self != .begin && currentStep.self != .loadingForRegistration {
                        Button {
                            withAnimation(.easeOut(duration: 0.3)) {
                                currentStep.prev()
                            }
                        } label: {
                            Text("Назад")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                                .padding(.vertical)
                                .frame(maxWidth: UIScreen.main.bounds.width / 4)
                                .background {
                                    RoundedRectangle(
                                        cornerRadius: .indicatorWidth,
                                        style: .continuous
                                    )
                                    .fill(.bar)
                                }
                        }
                        .transition(.move(edge: .leading).combined(with: .slide))
                        .buttonStyle(.plain)
                    }
                    
                    Button {
                        withAnimation(.easeOut(duration: 0.3)) {
                            currentStep.next()
                        }
                    } label: {
                        Label {
                            Text(currentStep.buttonTitle)
                                .overlay {
                                    ProgressView()
                                        .tint(colorScheme == .light ? .white : .black)
                                        .opacity(currentStep == .loadingForRegistration ? 1 : 0)
                                        .transition(.move(edge: .trailing))
                                }
                        } icon: {
                            if let systemImage = currentStep.systemImage {
                                Image(systemName: systemImage)
                            }
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background {
                            if currentStep != .loadingForRegistration {
                                RoundedRectangle(
                                    cornerRadius: .indicatorWidth,
                                    style: .continuous
                                )
                                .fill()
                                .matchedGeometryEffect(
                                    id:  String.registrationLoadingId,
                                    in: loadingIndicator
                                )
                            } else {
                                Circle()
                                    .fill()
                                    .matchedGeometryEffect(
                                        id: String.registrationLoadingId,
                                        in: loadingIndicator
                                    )
                                
                                Button {
                                    currentStep = .end
                                } label: {
                                    Image(systemName: .cancelSystemImage)
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.gray.opacity(0.35))
                                        .contentShape(.circle)
                                }
                                .offset(x: 60)
                                .transition(.move(edge: .leading))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        currentStep == .begin
                        ? emailValidator.isFullyValid
                        ? false : true
                        : currentStep == .middle
                        ? true : false
                    )
                }
                .padding(.horizontal, 32)
            }
            .animation(
                currentStep != .loadingForRegistration
                ? .customBouncy
                : .interpolatingSpring,
                value: currentStep)
        }
    }
    
    private struct IndicatorView: View {

        var currentStep: RegistrationSteps
        private var currentWidth: CGFloat {
            currentStep.self == .loadingForRegistration ? 0
            : CGFloat((currentStep.rawValue + 1) * Int(CGFloat.indicatorWidth) + (currentStep.rawValue) * Int(CGFloat.innerSpacing))
        }
        
        var body: some View {
            ZStack {
                HStack(spacing: .innerSpacing) {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(.clear)
                            .frame(width: .indicatorWidth)
                            .overlay {
                                Circle()
                                    .fill(.bar)
                                    .frame(width: .indicatorWidth / 2)
                                    .opacity(currentStep != .loadingForRegistration ? 1 : 0)
                            }
                    }
                }
            }
            .background(alignment: .leading) {
                RoundedRectangle(cornerRadius: .indicatorWidth / 2)
                    .fill(.green)
                    .frame(width: currentWidth)
            }
        }
    }
    
    private struct CurrentRegistrationView: View {
        
        @Binding var registrationStep: RegistrationSteps
        @Binding var email: String
        @State private var toast: Toast? = nil
        
        var validator: EmailValidator {
            EmailValidator(email: email)
        }
        
        var body: some View {
            
            switch registrationStep {
            case .begin:
                InitialRegistrationView(email: $email, validator: validator)
            case .middle:
                EmailConfirmView(toast: $toast, email: email)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.customBouncy) {
                                registrationStep = .end
                            }
                        }
                    }
            case .end:
                ProfileSetupView()
            case .loadingForRegistration:
                Color.clear
            }
        }
    }
    
    private struct InitialRegistrationView: View {
        
        @Binding var email: String
        var validator: IEmailValidator
        
        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                Text("Регистрация")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                TextField("Введите свой email", text: $email)
                    .accentColor(.gray)
                    .font(.title3)
                    .foregroundStyle(.black)
                    .padding()
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .transition(.opacity)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .transition(.move(edge: .leading))
                
                VStack(alignment: .leading, spacing: 8) {
                    BulletRuleView(isCompleted: validator.containsOneAtAndDot) {
                        Text("Разрешен один спецсимвол @ и .")
                    }
                    BulletRuleView(isCompleted: validator.containsOnlyAllowedCharacters) {
                        Text("Только разрешенные символы")
                    }
                    BulletRuleView(isCompleted: validator.hasValidDomain) {
                        HStack(spacing: 0) {
                            Text("Корректная доменная часть, например ")
                            Text(".com")
                                .foregroundStyle(.black)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private struct EmailConfirmView: View {
        
        @Binding var toast: Toast?
        var email: String
        
        var body: some View {
            ZStack {
                Image(.pers3)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width / 1.5)
                    .safeAreaPadding(.bottom, 32)
                    .background(
                        Circle()
                            .fill(.white)
                            .frame(width: UIScreen.main.bounds.width / 2.5)
                    )
                    .onAppear {
                        toast = .init(style: .success, message: "Подтверждени отправлено на адрес: \(email)")
                    }
            }
            .TopToastView(toast: $toast)
        }
    }
    
    private struct ProfileSetupView: View {
        
        var email: String = "zabinskiy.danil@mail.ru"
        @State private var vStackHeight: CGFloat = 0
        
        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    Text("О себе")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                VStack {
                    Image(.sample)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width / 2 * 0.65)
                        .clipShape(.circle)
                        .overlay(alignment: .trailing) {
                            Circle()
                                .fill(Color(uiColor: .systemGray6))
                                .frame(width: UIScreen.main.bounds.width / 2 * 0.65 / 4 + 5)
                                .overlay {
                                    Image(systemName: "camera.fill")
                                        .foregroundStyle(.gray)
                                }
                                .offset(x: -15, y: UIScreen.main.bounds.width / 4 * 0.65 - 15)
                        }
                    
                    Text(email)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding()
                .readHeight { height in
                    self.vStackHeight = height
                }
                .frame(maxWidth: .infinity)
                .frame(height: vStackHeight)
                .background {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            }
            .padding()
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func readHeight(onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

#Preview {
    RegistrationView()
}

private extension RegistrationSteps {
    
    var buttonTitle: String {
        switch self {
        case .begin:
            return "Далее"
        case .middle:
            return "Подтвердите почту"
        case .end:
            return "Готово"
        default:
            return ""
        }
    }
    
    var systemImage: String? {
        switch self {
        case .end:
            return "checkmark.circle.fill"
        default:
            return nil
        }
    }
    
    mutating func next() {
        switch self {
        case .begin:
            self = .middle
        case .middle:
            self = .end
        case .end:
            self = .loadingForRegistration
        default:
            break
        }
    }
    
    mutating func prev() {
        switch self {
        case .begin:
            print("start")
        case .middle:
            self = .begin
        case .end:
            self = .middle
        default:
            break
        }
    }
}

private extension Animation {
    static let customBouncy: Animation = .bouncy(duration: 0.4, extraBounce: 0.15)
}

private extension CGFloat {
    static let indicatorWidth: Self = 30
    static let innerSpacing: Self = 20
    static let onboardingOverlayHeight: CGFloat = 150
    static let onboardingOverlayRadius: CGFloat = 45
}

private extension String {
    static let registrationLoadingId = "REGISTRATION_LOADING"
    static let emailFiledId = "REGISTERED_EMAIL"
    static let cancelSystemImage = "xmark.circle.fill"
}
