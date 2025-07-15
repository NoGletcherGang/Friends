import Foundation

protocol IEmailValidator {
    
    var containsOneAtAndDot: Bool { get }
    var containsOnlyAllowedCharacters: Bool { get }
    var hasValidDomain: Bool { get }
    var isFullyValid: Bool { get }
}

struct EmailValidator: IEmailValidator {
    let email: String

    var containsOneAtAndDot: Bool {
        let atCount = email.filter { $0 == "@" }.count
        let dotCount = email.filter { $0 == "." }.count
        return atCount == 1 && dotCount >= 1
    }

    var containsOnlyAllowedCharacters: Bool {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@._%+-")
        return email.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }

    var hasValidDomain: Bool {
        let parts = email.split(separator: "@")
        guard parts.count == 2 else { return false }

        let domainPart = parts[1]
        let domainComponents = domainPart.split(separator: ".")

        guard domainComponents.count >= 2 else { return false }

        guard domainComponents.allSatisfy({ !$0.isEmpty }) else { return false }

        guard let tld = domainComponents.last,
              tld.count >= 2,
              tld.allSatisfy({ $0.isLetter }) else {
            return false
        }

        return true
    }

    var isFullyValid: Bool {
        containsOneAtAndDot && containsOnlyAllowedCharacters && hasValidDomain
    }
}
