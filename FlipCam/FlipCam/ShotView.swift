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
				CameraPreview(source: viewModel.previewSource, camera: viewModel.cameraController)
					.task {
						await viewModel.startCamera()
					}
					.aspectRatio(3/4, contentMode: .fit)
					.overlay(alignment: .center) {
						GeometryReader { geometry in
							if viewModel.shouldShowGuidePhoto {
								guidePhoto(width: geometry.size.width, height: geometry.size.height, viewModel: viewModel)
							}
						}
					}
			}
			.overlay(alignment: .center) {
				GeometryReader { geometry in
					if viewModel.shouldShowGuideGrid {
						gridLines
							.frame(width: geometry.size.width, height: geometry.size.height)
					}
				}
			}
			GuideControl(viewModel: viewModel)
			OpacityControl(viewModel: viewModel)
			MainToolbar(viewModel: viewModel)
		}
		.alert(ErrorMessages.error, isPresented: .constant(viewModel.showErrorAlert)) {
			if let error = viewModel.error as? CameraError, error.isFatalError {
				Button(ErrorMessages.exitFlipCam) {
					fatalError(error.localizedDescription)
				}
			} else {
				Button(ErrorMessages.ok) {
					viewModel.showErrorAlert = false
				}
			}
		} message: {
			Text(viewModel.error?.localizedDescription ?? ErrorMessages.restart)
		}
	}

	@ViewBuilder
	private func guidePhoto(width: CGFloat, height: CGFloat, viewModel: ShotViewModel) -> some View {
		if let processedGuidePhoto = viewModel.processedGuidePhoto {
			Image(uiImage: processedGuidePhoto)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: width, height: height)
				.clipped()
				.opacity(viewModel.guidePhotoOpacity)
		}
	}

	@ViewBuilder
	private var gridLines: some View {
		GridLines()
			.stroke(Color.themeAccentWithOpacity(colorScheme: colorScheme), lineWidth: 1.0)
			.allowsHitTesting(false)
	}

}
