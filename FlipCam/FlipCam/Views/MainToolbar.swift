//
//  MainToolbar.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/16.
//

import SwiftUI
import PhotosUI

struct MainToolbar: PlatformView {

	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.colorScheme) var colorScheme

	@State var viewModel: ShotViewModelType

	var body: some View {
		HStack {
			HStack(spacing: 20) {
				ThumbnailButton(viewModel: viewModel)
				FlashlightButton(viewModel: viewModel)
			}
			Spacer()
			CaptureButton(viewModel: viewModel)
			Spacer()
			HStack(spacing: 20) {
				Color.clear
					.frame(width: 44, height: 44)
				SwitchCameraButton(viewModel: viewModel)
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
