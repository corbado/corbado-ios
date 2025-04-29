import SwiftUI
import CorbadoIOS

struct ContentView: View {
    @State private var greeting: String = "Loading…"
    
    var body: some View {
        VStack {
            Text(greeting)
                .font(.subheadline)
        }
        .padding()
        // Kick off the async call when this view appears
        .task {
            // Call your async API wrapper
            greeting = await CorbadoIOS.sayHello()
        }
    }
}

#Preview {
    ContentView()
}
