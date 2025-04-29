//
//  ScreenHeadline.swift
//  ConnectExample
//
//  Created by Martin on 16/5/2025.
//

import SwiftUI

struct ScreenHeadline: View {
    let title: String
    let accessibilityIdentifier: String
    
    var body: some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
            .multilineTextAlignment(.center)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}
