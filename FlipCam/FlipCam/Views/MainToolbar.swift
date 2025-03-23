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
	@Environment(\.colorScheme) var colorScheme

	@State var camera: CameraModel

	var body: some View {
		HStack {
			HStack(spacing: 20) {
				ThumbnailButton(camera: camera)
				FlashlightButton(camera: camera)
			}
			Spacer()
			CaptureButton(camera: camera)
			Spacer()
			HStack(spacing: 20) {
				Color.clear
					.frame(width: 44, height: 44)
				SwitchCameraButton(camera: camera)
			}
		}
		.foregroundColor(Color.themeForeground(colorScheme: colorScheme))
		.font(.system(size: 24))
		.frame(width: width, height: height)
		.padding([.leading, .trailing])
	}

	var width: CGFloat? { isRegularSize ? 250 : nil }
	var height: CGFloat? { 80 }
}
