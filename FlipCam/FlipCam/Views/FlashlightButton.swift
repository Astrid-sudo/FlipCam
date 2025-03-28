//
//  FlashlightButton.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/18.
//

import SwiftUI

struct FlashlightButton: View {

	@State var viewModel: ShotViewModelType
	@Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button {
            Task {
				switch viewModel.output.flashMode {
                case .off:
					await viewModel.input.setFlashMode(.on)
                case .on:
                    await viewModel.input.setFlashMode(.auto)
                case .auto:
                    await viewModel.input.setFlashMode(.off)
                @unknown default:
                    await viewModel.input.setFlashMode(.off)
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
        switch viewModel.output.flashMode {
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
        switch viewModel.output.flashMode {
        case .off:
			return Color.themeForeground(colorScheme: colorScheme)
        case .on:
			return Color.themeAccent(colorScheme: colorScheme)
        case .auto:
			return Color.themeAccent(colorScheme: colorScheme)
        }
    }
} 
