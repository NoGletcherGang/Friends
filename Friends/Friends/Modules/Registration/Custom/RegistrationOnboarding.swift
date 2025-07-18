import SwiftUI

struct Intro {
    
    var id: UUID = .init()
    var text: String
    var textColor: Color
    var circleColor: Color
    var bgColor: Color
    var circleOffset: CGFloat = 0
    var textOffset: CGFloat = 0
    
    static func sample() -> [Self] {
        [
            .init(
                text: "Планировать",
                textColor: .gray,
                circleColor: .init(uiColor: .systemGray3),
                bgColor: .init(uiColor: .systemGray6)
            ),
            .init(
                text: "Собираться вместе",
                textColor: .gray,
                circleColor: .gray,
                bgColor: .init(uiColor: .systemGray6)
            ),
            .init(
                text: "Новые знакомства",
                textColor: .gray,
                circleColor: .init(uiColor: .systemGray3),
                bgColor: .init(uiColor: .systemGray6)
            ),
            .init(
                text: "Удовольствие",
                textColor: .gray,
                circleColor: .init(uiColor: .systemGray3),
                bgColor: .init(uiColor: .systemGray6)
            ),
            .init(
                text: "Планировать",
                textColor: .gray,
                circleColor: .init(uiColor: .systemGray3),
                bgColor: .init(uiColor: .systemGray6)
            )
        ]
    }
}

struct RegistrationOnboardingView: View {
    
    @State private var intros = Intro.sample()
    @State private var activeIntro: Intro?
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack(spacing: 0) {
                if let activeIntro {
                    Rectangle()
                        .fill(activeIntro.bgColor)
                        .overlay {
                            Circle()
                                .fill(activeIntro.circleColor)
                                .frame(width: 38)
                                .background(alignment: .leading) {
                                    Capsule()
                                        .fill(activeIntro.bgColor)
                                        .frame(width: size.width)
                                }
                                .background(alignment: .leading) {
                                    Text(activeIntro.text)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(activeIntro.textColor)
                                        .frame(width: textSize(activeIntro.text))
                                        .offset(x: 20)
                                        .offset(x: activeIntro.textOffset)
                                }
                                .offset(x: -activeIntro.circleOffset)
                        }
                }
            }
            .ignoresSafeArea()
        }
        .task {
            if activeIntro == nil {
                activeIntro = intros.first
                
                let oneSecond = UInt64(1_000_000_000)
                try? await Task.sleep(nanoseconds: oneSecond * UInt64(0.15))
                
                animate(0)
            }
        }
    }
    
    func animate(_ index: Int) {
        if intros.indices.contains(index + 1) {
            activeIntro?.text = intros[index].text
            activeIntro?.textColor = intros[index].textColor
            
            withAnimation(.snappy(duration: 1), completionCriteria: .removed) {
                activeIntro?.textOffset = -(textSize(intros[index].text) + 20)
                activeIntro?.circleOffset = -(textSize(intros[index].text) + 20) /  2
            } completion: {
                withAnimation(.snappy(duration: 1), completionCriteria: .logicallyComplete) {
                    activeIntro?.textOffset = 0
                    activeIntro?.circleOffset = 0
                    activeIntro?.circleColor = intros[index + 1].circleColor
                    activeIntro?.bgColor = intros[index + 1].bgColor
                } completion: {
                    animate(index + 1)
                }
            }
        } else {
            animate(0)
        }
    }
    
    func textSize(_ text: String) -> CGFloat {
        NSString(string: text).size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: .largeTitle)]).width
    }
}
