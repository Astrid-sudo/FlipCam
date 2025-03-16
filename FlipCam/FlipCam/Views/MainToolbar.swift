//
//  MainToolbar.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/16.
//

import SwiftUI
import PhotosUI

struct MainToolbar<CameraModel: Camera>: PlatformView {

	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment(\.horizontalSizeClass) var horizontalSizeClass

	@State var camera: CameraModel

	var body: some View {
		HStack {
			ThumbnailButton(camera: camera)
			// Hide the thumbnail button when a person interacts with capture controls.
				.opacity(camera.prefersMinimizedUI ? 0 : 1)
			Spacer()
			CaptureButton(camera: camera)
			Spacer()
			SwitchCameraButton(camera: camera)
				.opacity(camera.prefersMinimizedUI ? 0 : 1)
		}
		.foregroundColor(.white)
		.font(.system(size: 24))
		.frame(width: width, height: height)
		.padding([.leading, .trailing])
	}

	var width: CGFloat? { isRegularSize ? 250 : nil }
	var height: CGFloat? { 80 }
}
