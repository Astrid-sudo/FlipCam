//
//  GuideControl.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/17.
//

import SwiftUI

struct GuideControl<CameraModel: Camera>: PlatformView {

	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment(\.horizontalSizeClass) var horizontalSizeClass

	let camera: CameraModel

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
			EffectButton(systemName: "photo", 
						effect: .normal, 
						selectedEffect: Binding(
							get: { camera.currentGuidePhotoEffect },
							set: { camera.setGuidePhotoEffect($0) }
						))
			EffectButton(systemName: "circle.filled.pattern.diagonalline.rectangle", 
						effect: .contrast, 
						selectedEffect: Binding(
							get: { camera.currentGuidePhotoEffect },
							set: { camera.setGuidePhotoEffect($0) }
						))
			EffectButton(systemName: "circle.rectangle.filled.pattern.diagonalline", 
						effect: .inverse, 
						selectedEffect: Binding(
							get: { camera.currentGuidePhotoEffect },
							set: { camera.setGuidePhotoEffect($0) }
						))
			EffectButton(systemName: "applepencil.and.scribble", 
						effect: .outline, 
						selectedEffect: Binding(
							get: { camera.currentGuidePhotoEffect },
							set: { camera.setGuidePhotoEffect($0) }
						))
		}
		.adaptiveSpacing()
	}

	@ViewBuilder
	private var gridButton: some View {
		Button {
			camera.isGuideGridEnabled.toggle()
		} label: {
			Image(systemName: "grid")
				.foregroundColor(camera.isGuideGridEnabled ? .yellow : .white)
		}
	}

}

struct EffectButton: View {
	let systemName: String
	let effect: GuidePhotoEffect
	@Binding var selectedEffect: GuidePhotoEffect

	var body: some View {
		Button {
			selectedEffect = effect
		} label: {
			Image(systemName: systemName)
				.foregroundColor(selectedEffect == effect ? .yellow : .white)
				.adaptiveButtonSize()
		}
	}
}

/// Guide Photo Effects
enum GuidePhotoEffect: String, CaseIterable, Identifiable {
	case normal = "Normal"
	case contrast = "Contrast"
	case inverse = "Inverse"
	case outline = "Outline"

	var id: String { rawValue }
}
