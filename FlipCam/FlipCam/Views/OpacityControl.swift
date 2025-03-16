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
			} label: {
				Image(systemName: "eye")
					.font(.title2)
					.foregroundColor(.white)
					.padding()
			}

			Slider(value: Binding(
				get: { camera.guidePhotoOpacity },
				set: { camera.setGuidePhotoOpacity($0) }
			), in: 0.1...1.0, step: 0.05)

			Button {
			} label: {
				Image(systemName: "circle.lefthalf.filled")
					.font(.title2)
					.foregroundColor(.white)
					.padding()
			}
		}
	}
}
