import SwiftUI
import CorbadoConnect
import Factory

@MainActor
class HomeViewModel: ObservableObject {
    @Injected(\.corbadoService) private var corbado: Corbado
    
    @Published var showingBottomSheet: Bool = false
    @Published var isButton1PasskeyActive: Bool = false
    @Published var isButton2PasskeyActive: Bool = false
    @Published var isButton3PasskeyActive: Bool = false
    
    private var isAutoAppend = false
    
    func onAppear() {
        Task {
            let nextStep = await corbado.isAppendAllowed(situation: "home") { _ in
                return try await getConnectToken()
            }
            
            switch nextStep {
            case .askUserForAppend(let autoAppend, _, _, let customData):
                guard let customData = customData, let buttons = customData["buttons"] else {
                    return
                }
                
                let allowedButtons = buttons.split(separator: ",")
                if allowedButtons.contains("instant") {
                    if autoAppend {
                        await completePasskeyAppend(autoAppend: true)
                    } else {
                        askForPasskeyAppend()
                    }
                    
                    return
                }
                
                isAutoAppend = autoAppend
                for button in allowedButtons {
                    switch button {
                    case "button1":
                        isButton1PasskeyActive = true
                        
                    case "button2":
                        isButton2PasskeyActive = true
                        
                    case "button3":
                        isButton3PasskeyActive = true
                        
                    default:
                        continue
                    }
                }
                
            case .skip:
                1 == 1
            }
        }
    }
    
    func passkeyActiveButtonClicked() async {
        isButton1PasskeyActive = false
        isButton2PasskeyActive = false
        isButton3PasskeyActive = false
        
        if isAutoAppend {
            await completePasskeyAppend(autoAppend: true)
        } else {
            askForPasskeyAppend()
        }
    }
    
    func completePasskeyAppend(autoAppend: Bool) async {
        var completionType = AppendCompletionType.Manual
        if autoAppend {
            completionType = .Auto
        }
        
        let rsp = await corbado.completeAppend(completionType: completionType)
        switch rsp {
        case .cancelled:
            if autoAppend {
                askForPasskeyAppend()
            }
            return
            
        default:
            return
        }
    }
    
    private func getConnectToken() async throws -> String {
        let idToken = await AppBackend.getIdToken()
        return try await AppBackend.getConnectToken(connectTokenType: ConnectTokenType.PasskeyAppend, idToken: idToken!)
    }
    
    private func askForPasskeyAppend() {
        showingBottomSheet = true
    }
}

