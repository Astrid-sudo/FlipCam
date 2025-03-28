//
//  ShotView.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/6.
//

import SwiftUI

struct ShotView: View {
	@State private var viewModel: ShotViewModelType?
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
	private func mainContent(viewModel: ShotViewModelType) -> some View {
		VStack {
			PreviewContainer(camera: viewModel.output.cameraController) {
				CameraPreview(camera: viewModel.output.cameraController)
					.task {
						await viewModel.input.startCamera()
					}
					.aspectRatio(3/4, contentMode: .fit)
					.overlay(alignment: .center) {
						GeometryReader { geometry in
							if viewModel.output.shouldShowGuidePhoto {
								guidePhoto(width: geometry.size.width, height: geometry.size.height, viewModel: viewModel)
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
					viewModel.input.dismissAlert()
				}
			}
		} message: {
			Text(viewModel.output.error?.localizedDescription ?? ErrorMessages.restart)
		}
	}

	@ViewBuilder
	private func guidePhoto(width: CGFloat, height: CGFloat, viewModel: ShotViewModelType) -> some View {
		if let processedGuidePhoto = viewModel.output.processedGuidePhoto {
			Image(uiImage: processedGuidePhoto)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: width, height: height)
				.clipped()
				.opacity(viewModel.output.guidePhotoOpacity)
		}
	}

	@ViewBuilder
	private var gridLines: some View {
		GridLines()
			.stroke(Color.themeAccentWithOpacity(colorScheme: colorScheme), lineWidth: 1.0)
			.allowsHitTesting(false)
	}

}
