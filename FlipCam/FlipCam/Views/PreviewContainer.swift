//
//  PreviewContainer.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/19.
//

import SwiftUI

@MainActor
struct PreviewContainer<Content: View>: View {

	@Environment(\.horizontalSizeClass) var horizontalSizeClass

	@State var viewModel: ShotViewModelType

	@State private var blurRadius = CGFloat.zero

	private let content: Content

	init(viewModel: ShotViewModelType, @ViewBuilder content: () -> Content) {
		self.viewModel = viewModel
		self.content = content()
	}

	var body: some View {
		content
			.blur(radius: blurRadius, opaque: true)
			.overlay {
				if viewModel.output.shouldFlashScreen {
					Color.black
						.ignoresSafeArea()
				}
			}
			.onChange(of: viewModel.output.isSwitchingCameraDevices, updateBlurRadius(_:_:))
	}

	func updateBlurRadius(_: Bool, _ isSwitching: Bool) {
		withAnimation {
			blurRadius = isSwitching ? 10 : 0
		}
	}
}
