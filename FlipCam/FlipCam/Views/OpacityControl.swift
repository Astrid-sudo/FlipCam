//
//  OpacityControl.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/17.
//

import SwiftUI

struct OpacityControl<CameraModel: Camera>: PlatformView {

	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.colorScheme) var colorScheme

	@State var camera: CameraModel

	var body: some View {
		HStack {
			Button {
				camera.toggleGuidePhotoVisibility()
			} label: {
				Image(systemName: camera.shouldShowGuidePhoto ? "eye" : "eye.slash")
					.adaptiveSpacing()
					.foregroundColor(camera.shouldShowGuidePhoto ? Color.themeAccent(colorScheme: colorScheme) : Color.themeForeground(colorScheme: colorScheme))
					.adaptiveButtonSize()
			}

			Slider(value: Binding(
				get: { camera.guidePhotoOpacity },
				set: { camera.setGuidePhotoOpacity($0) }
			), in: 0.1...1.0, step: 0.05)
			.tint(Color.themeAccent(colorScheme: colorScheme))

			Button {
				camera.setGuidePhotoOpacity(0.5)
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
