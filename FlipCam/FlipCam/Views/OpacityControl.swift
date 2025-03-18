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

	@State var camera: CameraModel

	var body: some View {
		HStack {
			Button {
				camera.toggleGuidePhotoVisibility()
			} label: {
				Image(systemName: camera.shouldShowGuidePhoto ? "eye" : "eye.slash")
					.font(.title2)
					.foregroundColor(camera.shouldShowGuidePhoto ? .yellow : .white)
					.padding()
			}

			Slider(value: Binding(
				get: { camera.guidePhotoOpacity },
				set: { camera.setGuidePhotoOpacity($0) }
			), in: 0.1...1.0, step: 0.05)

			Button {
				camera.setGuidePhotoOpacity(0.5)
			} label: {
				Image(systemName: "circle.lefthalf.filled")
					.font(.title2)
					.foregroundColor(.white)
					.padding()
			}
		}
	}
}
