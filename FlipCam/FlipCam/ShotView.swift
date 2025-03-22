//
//  ShotView.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/6.
//

import SwiftUI

struct ShotView: View {
	@State private var camera = ShotViewModel()
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		VStack {
			PreviewContainer(camera: camera) {
				CameraPreview(source: camera.previewSource, camera: camera)
					.task {
						await camera.start()
					}
					.aspectRatio(3/4, contentMode: .fit)
					.overlay(alignment: .center) {
						GeometryReader { geometry in
							if camera.shouldShowGuidePhoto {
								guidePhoto(width: geometry.size.width, height: geometry.size.height)
							}
						}
					}
			}
			.overlay(alignment: .center) {
				GeometryReader { geometry in
					if camera.isGuideGridEnabled {
						gridLines
							.frame(width: geometry.size.width, height: geometry.size.height)
					}
				}
			}
			GuideControl(camera: camera)
			OpacityControl(camera: camera)
			MainToolbar(camera: camera)
		}
		.alert("Error", isPresented: .constant(camera.showErrorAlert)) {
			Button("OK") {
				camera.showErrorAlert = false
			}
		} message: {
			Text(camera.error?.localizedDescription ?? "Error occurred, please restart the app.")
		}
	}

	@ViewBuilder
	private func guidePhoto(width: CGFloat, height: CGFloat) -> some View {
		if let processedGuidePhoto = camera.processedGuidePhoto {
			Image(uiImage: processedGuidePhoto)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: width, height: height)
				.clipped()
				.opacity(camera.guidePhotoOpacity)
		}
	}

	@ViewBuilder
	private var gridLines: some View {
		GridLines()
			.stroke(Color.themeAccentWithOpacity(colorScheme: colorScheme), lineWidth: 1.0)
			.allowsHitTesting(false)
	}

}
