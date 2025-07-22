//
//  PasskeyListEntry.swift
//  ConnectExample
//
//  Created by Martin on 12/5/2025.
//

import CorbadoConnect
import SwiftUI

struct StatusBadge: View {
    let text: String
    let iconName: String
    let color: Color = .green // Badge color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .imageScale(.small) // Match icon size better with text
            Text(text)
        }
        .font(.caption.weight(.medium)) // Slightly bolder caption
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.15)) // Light background
        .foregroundColor(color)          // Text and icon color
        .clipShape(Capsule())            // Rounded ends like a capsule
    }
}

struct PasskeyListEntry: View {
    let passkey: Passkey
    let onDelete: () async -> Void
    
    let isSynced: Bool = true
    let isHybrid: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Image(systemName: "apple.logo") // Standard Apple logo SF Symbol
                    .font(.title2) // Adjust size as needed
                
                Text(passkey.aaguidDetails.name)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    Task {
                        await onDelete()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
            }
            
            // Middle row: Status Badges
            HStack(spacing: 8) {
                if isSynced {
                    StatusBadge(text: "Synced", iconName: "arrow.triangle.2.circlepath")
                }
                if isHybrid {
                    StatusBadge(text: "Hybrid", iconName: "checkmark.shield")
                }
            }
            
            // Info Text: Created
            Text("Created: \(formattedDate(from: passkey.createdMs)) with \(passkey.sourceBrowser) on \(passkey.sourceOS)")
                .font(.footnote)
                .foregroundColor(.secondary) // Grayish text
            
            // Info Text: Last Used
            Text("Last used: \(formattedDate(from: passkey.lastUsedMs))")
                .font(.footnote)
                .foregroundColor(.secondary) // Grayish text
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("passkeyListEntry_\(passkey.id)")
    }
    
    func formattedDate(from milliseconds: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return formatter.string(from: date)
    }
}

/*
struct PasskeyListEWntry_Previews: PreviewProvider {
    static var previews: some View {
        PasskeyListEntry(
            passkey: Passkey(
                id: "id", credentialID: "credentialID", attestationType: "attestationType", transport: [.hybrid],
                backupEligible: true, backupState: true, authenticatorAAGUID: "authenticatorAAGUID", sourceOS: "iOS",
                sourceBrowser: "Chrome", lastUsed: "07-05-2025 20:29:19", created: "07-05-2025 20:29:19",
                status: .active, aaguidDetails: AaguidDetails(name: "iCloud KeyChain", iconLight: "String", iconDark: "String")
            ),
            onDelete: { }
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
*/

