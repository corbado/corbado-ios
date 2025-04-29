//
//  ContentView.swift
//  corbadoiosexample
//
//  Created by Mohamed Amine Hamdouni on 29.04.25.
//

import SwiftUI
import CorbadoIOS

struct ContentView: View {
    var body: some View {
        VStack {
            Text(CorbadoIOS.sayHello())
                            .font(.subheadline)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
