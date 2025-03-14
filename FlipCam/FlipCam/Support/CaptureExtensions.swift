//
//  CaptureExtensions.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/14.
//

import AVFoundation

extension CMVideoDimensions: @retroactive Equatable, @retroactive Comparable {

	static let zero = CMVideoDimensions()

	public static func == (lhs: CMVideoDimensions, rhs: CMVideoDimensions) -> Bool {
		lhs.width == rhs.width && lhs.height == rhs.height
	}

	public static func < (lhs: CMVideoDimensions, rhs: CMVideoDimensions) -> Bool {
		lhs.width < rhs.width && lhs.height < rhs.height
	}
}
