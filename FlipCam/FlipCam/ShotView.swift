//
//  ShotView.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/6.
//

import SwiftUI

struct ShotView: View {
	@State private var viewModel: ShotViewModel?
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		Group {
			if let viewModel {
				mainContent(viewModel: viewModel)
			} else {
				ProgressView()
			}
		}
		.task {
			viewModel = await ShotViewModel.create()
		}
	}

	@ViewBuilder
	private func mainContent(viewModel: ShotViewModel) -> some View {
		VStack {
			PreviewContainer(camera: viewModel.cameraController) {
				CameraPreview(camera: viewModel.cameraController)
					.onAppear {
						viewModel.input.startCamera.send()
					}
					.aspectRatio(3/4, contentMode: .fit)
					.overlay(alignment: .center) {
						GeometryReader { geometry in
							if viewModel.output.shouldShowGuidePhoto {
								guidePhoto(width: geometry.size.width, height: geometry.size.height)
							}
						}
					}
			}
			.overlay(alignment: .center) {
				GeometryReader { geometry in
					if viewModel.output.shouldShowGuideGrid {
						gridLines
							.frame(width: geometry.size.width, height: geometry.size.height)
					}
				}
			}
			GuideControl(viewModel: viewModel)
			OpacityControl(viewModel: viewModel)
			MainToolbar(viewModel: viewModel)
		}
		.alert(ErrorMessages.error, isPresented: .constant(viewModel.output.showErrorAlert)) {
			if let error = viewModel.output.error as? CameraError, error.isFatalError {
				Button(ErrorMessages.exitFlipCam) {
					fatalError(error.localizedDescription)
				}
			} else {
				Button(ErrorMessages.ok) {
					viewModel.output.showErrorAlert = false
				}
			}
		} message: {
			Text(viewModel.output.error?.localizedDescription ?? ErrorMessages.restart)
		}
	}

	@ViewBuilder
	private func guidePhoto(width: CGFloat, height: CGFloat) -> some View {
		if let processedGuidePhoto = viewModel?.output.processedGuidePhoto {
			Image(uiImage: processedGuidePhoto)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: width, height: height)
				.clipped()
				.opacity(viewModel?.output.guidePhotoOpacity ?? 0.5)
		}
	}

	@ViewBuilder
	private var gridLines: some View {
		GridLines()
			.stroke(Color.themeAccentWithOpacity(colorScheme: colorScheme), lineWidth: 1.0)
			.allowsHitTesting(false)
	}

}
