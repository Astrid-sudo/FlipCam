//
//  SwitchCameraButton.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/16.
//

import SwiftUI

struct SwitchCameraButton: View {

	@State var viewModel: ShotViewModel

	var body: some View {
		Button {
			Task {
				await viewModel.switchCameraDevices()
			}
		} label: {
			Image(systemName: "arrow.triangle.2.circlepath")
				.adaptiveSpacing()
				.adaptiveButtonSize()
		}
		.allowsHitTesting(!viewModel.cameraController.isSwitchingCameraDevices)
	}
}
