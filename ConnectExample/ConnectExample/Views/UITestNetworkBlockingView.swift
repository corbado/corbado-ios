//
//  UITestNetworkBlockingView.swift
//  ConnectExample
//
//  Created by Martin on 30/4/2025.
//

import SwiftUI
import CorbadoConnect
import Factory

struct UITestNetworkBlockingView: View {
    @Injected(\.corbadoService) private var corbado: Corbado
    @State private var urlToBlock: String = ""

    var body: some View {
        HStack {
            TextField("", text: $urlToBlock)
                .accessibilityIdentifier("main.networkBlocking")
                .autocapitalization(.none)
                .onSubmit {
                    Task {
                        await corbado.setApiInterceptor(apiConfigInterceptor: BlockingOpenAPIInterceptor(urlToBlock: urlToBlock))
                    }
                }
        }
        .opacity(0.5)
        .padding()
    }
} 