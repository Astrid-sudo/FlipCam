//
//  SwitchCameraButton.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/16.
//

import SwiftUI

struct SwitchCameraButton: View {

	@State var viewModel: ShotViewModelType

	var body: some View {
		Button {
			Task {
				await viewModel.input.switchCameraDevices()
			}
		} label: {
			Image(systemName: SystemImageNames.cameraSwitch)
				.adaptiveSpacing()
				.adaptiveButtonSize()
		}
		.allowsHitTesting(!viewModel.output.cameraController.isSwitchingCameraDevices)
	}
}
