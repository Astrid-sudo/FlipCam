//
//  FlipCamApp.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/6.
//
import os
import SwiftUI
import PhotosUI
import Photos


@main
struct FlipCamApp: App {
	@State private var camera = ShotViewModel()

    var body: some Scene {
        WindowGroup {
			CameraPreview(source: camera.previewSource, camera: camera)
				.task {
					await camera.start()
				}
				.overlay {
					VStack {
						guidePhotoOverlay
							.overlay {
								if camera.isGuideGridEnabled {
									GridLines()
										.stroke(Color.white.opacity(0.7), lineWidth: 1.0)
										.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3)
										.allowsHitTesting(false)
								}

							}
						Slider(value: Binding(
							get: { camera.guidePhotoOpacity },
							set: { camera.setGuidePhotoOpacity($0) }
						), in: 0.1...1.0, step: 0.05)
						HStack {
							Picker("Effect", selection: Binding(
								get: { camera.currentGuidePhotoEffect },
								set: { camera.setGuidePhotoEffect($0) }
							)) {
								ForEach(ShotViewModel.GuidePhotoEffect.allCases) { effect in
									Text(effect.rawValue).tag(effect)
								}
							}
							.pickerStyle(.segmented)
							.padding()

							Button(action: {
								camera.toggleGuideGrid()
							}) {
								Image(systemName: camera.isGuideGridEnabled ? "grid" : "grid.circle")
									.font(.system(size: 20))
									.foregroundColor(.white)
							}
						}
						MainToolbar(camera: camera)
					}
				}
        }
    }

	@ViewBuilder
	private var guidePhotoOverlay: some View {
		if let processedGuidePhoto = camera.processedGuidePhoto {
			Image(uiImage: processedGuidePhoto)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3, alignment: .center)
				.clipped()
				.opacity(camera.guidePhotoOpacity)
		}
	}

}
let logger = Logger()
