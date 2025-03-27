//
//  SwitchCameraButton.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/16.
//

import SwiftUI

struct SwitchCameraButton: View {
	let viewModel: ShotViewModelType
	
	var body: some View {
		Button {
			viewModel.input.switchCameraDevices.send()
		} label: {
			Image(systemName: SystemImageNames.cameraSwitch)
				.adaptiveSpacing()
				.adaptiveButtonSize()
		}
		.allowsHitTesting(!viewModel.output.isSwitchingCameraDevices)
	}
}
