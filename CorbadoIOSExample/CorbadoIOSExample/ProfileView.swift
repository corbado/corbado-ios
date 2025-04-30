import SwiftUI

struct ProfileView: View {
    var username: String
    var onLogout: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)

            Text(username)
                .font(.title)
                .bold()

            Text("\(username.lowercased())@example.com")
                .foregroundColor(.secondary)

            Button(action: onLogout) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(username: "User") { }
    }
}