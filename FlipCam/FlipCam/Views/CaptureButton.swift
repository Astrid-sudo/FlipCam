//
//  CaptureButton.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/16.
//

import SwiftUI

@MainActor
struct CaptureButton<CameraModel: Camera>: View {

	@State var camera: CameraModel
	@Environment(\.horizontalSizeClass) var horizontalSizeClass

	private var mainButtonDimension: CGFloat {
		horizontalSizeClass == .regular ? 88 : 68
	}

	var body: some View {
		PhotoCaptureButton {
			Task {
				await camera.capturePhoto()
			}
		}
		.aspectRatio(1.0, contentMode: .fit)
		.frame(width: mainButtonDimension)
	}
}

private struct PhotoCaptureButton: View {
	private let action: () -> Void
	private let lineWidth = CGFloat(4.0)

	init(action: @escaping () -> Void) {
		self.action = action
	}

	var body: some View {
		ZStack {
			Circle()
				.stroke(lineWidth: lineWidth)
				.fill(.white)
			Button {
				action()
			} label: {
				Circle()
					.inset(by: lineWidth * 1.2)
					.fill(.white)
			}
			.buttonStyle(PhotoButtonStyle())
		}
	}

	struct PhotoButtonStyle: ButtonStyle {
		func makeBody(configuration: Configuration) -> some View {
			configuration.label
				.scaleEffect(configuration.isPressed ? 0.85 : 1.0)
				.animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
		}
	}
}
