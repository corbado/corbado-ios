//
//  Steps.swift
//  CorbadoIOS
//
//  Created by Martin on 5/5/2025.
//

public typealias Email = String
public typealias ErrorMessage = String
public typealias CUIChallenge = String
public typealias Session = String

public enum ConnectLoginStep {
    case InitFallback(Email? = nil, ErrorMessage? = nil)
    case InitTextField(CUIChallenge? = nil)
    case InitOneTap(Email)
    case Done(Session)
}

public struct ConnectLoginResult {
    let nextStep: ConnectLoginStep
    
    init(nextStep: ConnectLoginStep) {
        self.nextStep = nextStep
    }
}

public typealias autoAppend = Bool

public enum AppendVariant {
    case Default
}

public enum ConnectAppendStep {
    case AskUserForAppend(autoAppend = false, AppendVariant = .Default)
    case Skip
}

public enum ConnectAppendStatus {
    case Completed
    case Cancelled
    case Error
}
