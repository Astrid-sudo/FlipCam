//
//  ShotView.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/6.
//

import SwiftUI

struct ShotView: View {
	@State private var camera = ShotViewModel()

	var body: some View {
		VStack {
			CameraPreview(source: camera.previewSource, camera: camera)
				.debugBorder(color: Color.green)
				.task {
					await camera.start()
				}
				.overlay {
					if camera.shouldShowGuidePhoto {
						guidePhoto
					}
				}
				.overlay {
					if camera.isGuideGridEnabled {
						gridLines
					}
				}
			GuideControl(camera: camera)
			OpacityControl(camera: camera)
			MainToolbar(camera: camera)
		}
	}

	@ViewBuilder
	private var guidePhoto: some View {
		if let processedGuidePhoto = camera.processedGuidePhoto {
			Image(uiImage: processedGuidePhoto)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3, alignment: .center)
				.clipped()
				.opacity(camera.guidePhotoOpacity)
		}
	}

	@ViewBuilder
	private var gridLines: some View {
		GridLines()
			.stroke(Color.yellow.opacity(0.7), lineWidth: 1.0)
			.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3)
			.allowsHitTesting(false)
	}


}
