//
//  OpacityControl.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/17.
//

import SwiftUI

struct OpacityControl: PlatformView {

	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.colorScheme) var colorScheme

	@State var viewModel: ShotViewModel

	var body: some View {
		HStack {
			Button {
				viewModel.toggleGuidePhotoVisibility()
			} label: {
				Image(systemName: viewModel.shouldShowGuidePhoto ? "eye" : "eye.slash")
					.adaptiveSpacing()
					.foregroundColor(viewModel.shouldShowGuidePhoto ? Color.themeAccent(colorScheme: colorScheme) : Color.themeForeground(colorScheme: colorScheme))
					.adaptiveButtonSize()
			}

			Slider(value: Binding(
				get: { viewModel.guidePhotoOpacity },
				set: { viewModel.setGuidePhotoOpacity($0) }
			), in: 0.1...1.0, step: 0.05)
			.tint(Color.themeAccent(colorScheme: colorScheme))

			Button {
				viewModel.setGuidePhotoOpacity(0.5)
			} label: {
				Image(systemName: "circle.lefthalf.filled")
					.adaptiveSpacing()
					.foregroundColor(Color.themeForeground(colorScheme: colorScheme))
					.adaptiveButtonSize()
			}
		}
		.padding()
	}
}
