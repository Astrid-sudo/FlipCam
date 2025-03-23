//
//  ViewExtensions.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/16.
//

import SwiftUI
import UIKit

let largeButtonSize = CGSize(width: 64, height: 64)
let smallButtonSize = CGSize(width: 32, height: 32)

extension View {
	func adaptiveButtonSize() -> some View {
		self.modifier(AdaptiveButtonSize())
	}

	func adaptiveSpacing() -> some View {
		self.modifier(AdaptiveSpacing())
	}
}

struct AdaptiveButtonSize: ViewModifier {
	@Environment(\.horizontalSizeClass) var horizontalSizeClass

	func body(content: Content) -> some View {
		content
			.frame(width: horizontalSizeClass == .regular ? 44 : 36,
				   height: horizontalSizeClass == .regular ? 44 : 36)
	}
}

struct AdaptiveSpacing: ViewModifier {
	@Environment(\.horizontalSizeClass) var horizontalSizeClass

	func body(content: Content) -> some View {
		content
			.font(.system(size: horizontalSizeClass == .regular ? 32 : 24))
	}
}


@MainActor
protocol PlatformView: View {
	var verticalSizeClass: UserInterfaceSizeClass? { get }
	var horizontalSizeClass: UserInterfaceSizeClass? { get }
	var isRegularSize: Bool { get }
	var isCompactSize: Bool { get }
}

extension PlatformView {
	var isRegularSize: Bool { horizontalSizeClass == .regular && verticalSizeClass == .regular }
	var isCompactSize: Bool { horizontalSizeClass == .compact || verticalSizeClass == .compact }
}

extension Image {
	init(_ image: CGImage) {
		self.init(uiImage: UIImage(cgImage: image))
	}
}

extension View {
	func debugBorder(color: Color = .random) -> some View {
		self
			.border(color)
	}
}

extension Color {
	static var random: Color {
		Color(
			red: .random(in: 0...1),
			green: .random(in: 0...1),
			blue: .random(in: 0...1)
		)
	}
}
