//
//  GuideControl.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/17.
//

import SwiftUI

struct GuideControl: PlatformView {

	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.colorScheme) var colorScheme

	let viewModel: ShotViewModelType

	var body: some View {
			HStack {
				gridButton
				Spacer()
				effectButtonsRow
			}
			.padding()
	}

	@ViewBuilder
	private var effectButtonsRow: some View {
		HStack(spacing: horizontalSizeClass == .regular ? 20 : 10) {
			EffectButton(systemName: SystemImageNames.photo,
						effect: .normal,
						selectedEffect: viewModel.output.currentGuidePhotoEffect) {
				viewModel.input.setGuidePhotoEffect.send(.normal)
			}
			EffectButton(systemName: SystemImageNames.diagonalPatternRectangle,
						effect: .contrast,
						selectedEffect: viewModel.output.currentGuidePhotoEffect) {
				viewModel.input.setGuidePhotoEffect.send(.contrast)
			}
			EffectButton(systemName: SystemImageNames.diagonalPatternRectangleFilled,
						effect: .inverse,
						selectedEffect: viewModel.output.currentGuidePhotoEffect) {
				viewModel.input.setGuidePhotoEffect.send(.inverse)
			}
			EffectButton(systemName: SystemImageNames.pencilScribble,
						effect: .outline,
						selectedEffect: viewModel.output.currentGuidePhotoEffect) {
				viewModel.input.setGuidePhotoEffect.send(.outline)
			}
		}
		.adaptiveSpacing()
	}

	@ViewBuilder
	private var gridButton: some View {
		Button {
			viewModel.input.toggleGuideGrid.send()
		} label: {
			Image(systemName: SystemImageNames.grid)
				.foregroundColor(viewModel.output.shouldShowGuideGrid ? Color.themeAccent(colorScheme: colorScheme) : Color.themeForeground(colorScheme: colorScheme))
		}
	}

}

struct EffectButton: View {
	let systemName: String
	let effect: GuidePhotoEffect
	let selectedEffect: GuidePhotoEffect
	let action: () -> Void
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		Button(action: action) {
			Image(systemName: systemName)
				.foregroundColor(selectedEffect == effect ? Color.themeAccent(colorScheme: colorScheme) : Color.themeForeground(colorScheme: colorScheme))
				.adaptiveButtonSize()
		}
	}
}

