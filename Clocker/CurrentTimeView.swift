//
//  CurrentTimeView.swift
//  Clocker
//
//  Created by Jeff Zacharias on 7/22/23.
//  Copyright © 2023 Minimalist Code LLC. All rights reserved.
//

// Features
// - Updates every minute
// - Dim with swipe up/down
// - Move evey minute to prevent burn in

import SwiftUI

struct CurrentTimeView: View {
	@Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
	@Environment(\.colorScheme) private var colorScheme
	@AppStorage("opacity") var opacity: Double = 1.0
	@ObservedObject var clockSync = ClockSync()
	@State var timerBurnInMove = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	
	@State var isShowingSettingsButton = false
	var settingsButtonDisplaySeconds = 10
	@State var isShowingSettingsView = false
	
	let fontSizeTimePortrait: CGFloat = 110
	let fontSizeAmPmPortriat: CGFloat = 40
	let fontSizeTimeLandscape: CGFloat = 225
	let fontSizeAmPmLandscape: CGFloat = 75
	@State var fontSizeTime: CGFloat
	@State var fontSizeAmPm: CGFloat
	
	init() {
		_fontSizeTime = State(initialValue: fontSizeTimePortrait)
		_fontSizeAmPm = State(initialValue: fontSizeAmPmPortriat)
	}
	
	var body: some View {
		ZStack {
			Rectangle().foregroundColor(.clear) // Need to tap gesture to work on whole display
			HStack {
				Text(clockSync.timeString)
					.font(.system(size: fontSizeTime))
				Text(clockSync.amPmString)
					.font(.system(size: fontSizeAmPm))
			}
			.padding()
			.offset(CGSize(width: clockSync.offset, height: clockSync.offset))
			.opacity(opacity)
			.foregroundColor(colorScheme == .light ? .black : .white)
			.background(colorScheme == .light ? .white : .black)
			.preferredColorScheme(.dark)
			.statusBar(hidden: true)
			.persistentSystemOverlays(.hidden)
			.onAppear {
				updateOrientation()
				// Keep the display on all the time
				UIApplication.shared.isIdleTimerDisabled = true
				showSettingsButton()
			}
			.sheet(isPresented: $isShowingSettingsView) {
				InfoView()
			}
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
				updateOrientation()
			}
			if isShowingSettingsButton {
				SettingsButtonView(isShowingSettingsView: $isShowingSettingsView, opacity: $opacity)
			}
		}
		// This content shape and geture are needed to make the gesutre work over the whole display.
		.contentShape(Rectangle())
		.gesture(DragGesture(minimumDistance: 1, coordinateSpace: .local)
			.onChanged({ gesture in
				opacity = 1.0 - gesture.location.y / UIScreen.main.bounds.height
			})
		)
		.onTapGesture {
			showSettingsButton()
		}
	}
	
	struct SettingsButtonView: View {
		@Environment(\.colorScheme) private var colorScheme
		@Binding var isShowingSettingsView: Bool
		@Binding var opacity: Double
		
		var body: some View {
			VStack {
				HStack {
					Spacer()
					Button(action: {
						isShowingSettingsView = true
					}, label: {
						Image(systemName: "info.circle")
							.resizable()
							.frame(width: 25, height: 25)
							.foregroundColor(colorScheme == .light ? .black : .white)
							.background(colorScheme == .light ? .white : .black)
							.opacity(opacity)
					})
					.padding()
				}
				Spacer()
				Text("Swipe up/down to adjust brightness")
					.opacity(opacity)
			}
		}
	}
	
	// MARK: Functions
	
	func updateOrientation() {
		switch UIDevice.current.orientation {
		case .portrait:
			fontSizeTime = fontSizeTimePortrait
			fontSizeAmPm = fontSizeAmPmPortriat
		case .portraitUpsideDown:
			break
		case .landscapeLeft, .landscapeRight:
			fontSizeTime = fontSizeTimeLandscape
			fontSizeAmPm = fontSizeAmPmLandscape
		default:
			break
		}
	}
	
	func showSettingsButton() {
		Task {
			isShowingSettingsButton = true
			try? await Task.sleep(for: .seconds(settingsButtonDisplaySeconds))
			isShowingSettingsButton = false
		}
	}
}

#Preview {
	CurrentTimeView()
}
