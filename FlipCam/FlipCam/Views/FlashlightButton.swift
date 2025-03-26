//
//  FlashlightButton.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/18.
//

import SwiftUI

struct FlashlightButton<CameraModel: Camera>: View {

    @State var camera: CameraModel
	@Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button {
            Task {
                switch camera.flashMode {
                case .off:
                    await camera.setFlashMode(.on)
                case .on:
                    await camera.setFlashMode(.auto)
                case .auto:
                    await camera.setFlashMode(.off)
                @unknown default:
                    await camera.setFlashMode(.off)
                }
            }
        } label: {
            Image(systemName: flashIconName)
                .adaptiveSpacing()
                .foregroundColor(flashIconColor)
                .adaptiveButtonSize()
        }
    }
    
    private var flashIconName: String {
        switch camera.flashMode {
        case .off:
            return SystemImageNames.boltSlashFill
        case .on:
            return SystemImageNames.boltFill
        case .auto:
            return SystemImageNames.boltBadgeA
        @unknown default:
            return SystemImageNames.boltSlashFill
        }
    }
    
    private var flashIconColor: Color {
        switch camera.flashMode {
        case .off:
			return Color.themeForeground(colorScheme: colorScheme)
        case .on:
			return Color.themeAccent(colorScheme: colorScheme)
        case .auto:
			return Color.themeAccent(colorScheme: colorScheme)
        }
    }
} 
