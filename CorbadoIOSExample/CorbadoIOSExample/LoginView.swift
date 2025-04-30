import SwiftUI
import CorbadoIOS

struct LoginView: View {
    @Binding var username: String
    var onLogin: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .bold()

            TextField("Username", text: $username)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            Button(action: {
                // TODO: Add authentication logic
                onLogin()
            }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(username.isEmpty)

            Spacer()
        }
        .padding()
        .task({await CorbadoIOS.loginInit()})
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(username: .constant("")) { }
    }
}
