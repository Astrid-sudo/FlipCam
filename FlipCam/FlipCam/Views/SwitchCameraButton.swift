//
//  SwitchCameraButton.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/16.
//

import SwiftUI

struct SwitchCameraButton<CameraModel: Camera>: View {

	@State var camera: CameraModel

	var body: some View {
		Button {
			Task {
				await camera.switchCameraDevices()
			}
		} label: {
			Image(systemName: "arrow.triangle.2.circlepath")
		}
		.buttonStyle(DefaultButtonStyle(size: .large))
		.frame(width: largeButtonSize.width, height: largeButtonSize.height)
		.allowsHitTesting(!camera.isSwitchingCameraDevices)
	}
}
