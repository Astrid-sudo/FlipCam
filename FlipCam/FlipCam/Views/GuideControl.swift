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
						selectedEffect: Binding(
							get: { viewModel.output.currentGuidePhotoEffect },
							set: { viewModel.input.setGuidePhotoEffect($0) }
						))
			EffectButton(systemName: SystemImageNames.diagonalPatternRectangle, 
						effect: .contrast, 
						selectedEffect: Binding(
							get: { viewModel.output.currentGuidePhotoEffect },
							set: { viewModel.input.setGuidePhotoEffect($0) }
						))
			EffectButton(systemName: SystemImageNames.diagonalPatternRectangleFilled, 
						effect: .inverse, 
						selectedEffect: Binding(
							get: { viewModel.output.currentGuidePhotoEffect },
							set: { viewModel.input.setGuidePhotoEffect($0) }
						))
			EffectButton(systemName: SystemImageNames.pencilScribble, 
						effect: .outline, 
						selectedEffect: Binding(
							get: { viewModel.output.currentGuidePhotoEffect },
							set: { viewModel.input.setGuidePhotoEffect($0) }
						))
		}
		.adaptiveSpacing()
	}

	@ViewBuilder
	private var gridButton: some View {
		Button {
			viewModel.input.toggleGuideGrid()
		} label: {
			Image(systemName: SystemImageNames.grid)
				.foregroundColor(viewModel.output.shouldShowGuideGrid ? Color.themeAccent(colorScheme: colorScheme) : Color.themeForeground(colorScheme: colorScheme))
		}
	}

}

struct EffectButton: View {
	let systemName: String
	let effect: GuidePhotoEffect
	@Binding var selectedEffect: GuidePhotoEffect
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		Button {
			selectedEffect = effect
		} label: {
			Image(systemName: systemName)
				.foregroundColor(selectedEffect == effect ? Color.themeAccent(colorScheme: colorScheme) : Color.themeForeground(colorScheme: colorScheme))
				.adaptiveButtonSize()
		}
	}
}

