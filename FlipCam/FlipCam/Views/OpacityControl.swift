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

	let viewModel: ShotViewModelType

	var body: some View {
		HStack {
			Button {
				viewModel.input.toggleGuidePhotoVisibility.send()
			} label: {
				Image(systemName: viewModel.output.shouldShowGuidePhoto ? SystemImageNames.eye : SystemImageNames.eyeSlash)
					.adaptiveSpacing()
					.foregroundColor(viewModel.output.shouldShowGuidePhoto ? Color.themeAccent(colorScheme: colorScheme) : Color.themeForeground(colorScheme: colorScheme))
					.adaptiveButtonSize()
			}

			Slider(value: Binding(
				get: { viewModel.output.guidePhotoOpacity },
				set: { viewModel.input.setGuidePhotoOpacity.send($0) }
			), in: 0.1...1.0, step: 0.05)
			.tint(Color.themeAccent(colorScheme: colorScheme))

			Button {
				viewModel.input.setGuidePhotoOpacity.send(0.5)
			} label: {
				Image(systemName: SystemImageNames.circleLeftHalfFilled)
					.adaptiveSpacing()
					.foregroundColor(Color.themeForeground(colorScheme: colorScheme))
					.adaptiveButtonSize()
			}
		}
		.padding()
	}
}
