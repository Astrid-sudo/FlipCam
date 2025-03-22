//
//  PreviewContainer.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/19.
//

import SwiftUI

@MainActor
struct PreviewContainer<Content: View, CameraModel: Camera>: View {

	@Environment(\.horizontalSizeClass) var horizontalSizeClass

	@State var camera: CameraModel

	@State private var blurRadius = CGFloat.zero

	private let content: Content

	init(camera: CameraModel, @ViewBuilder content: () -> Content) {
		self.camera = camera
		self.content = content()
	}

	var body: some View {
		content
			.blur(radius: blurRadius, opaque: true)
			.overlay {
				if camera.shouldFlashScreen {
					Color.black
						.ignoresSafeArea()
				}
			}
			.onChange(of: camera.isSwitchingCameraDevices, updateBlurRadius(_:_:))
	}

	func updateBlurRadius(_: Bool, _ isSwitching: Bool) {
		withAnimation {
			blurRadius = isSwitching ? 10 : 0
		}
	}
}
