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
	@State var timeString = ""
	@State var amPmString = ""
	@State var offset = 0
	let maxOffset = 25
	@State var timerClock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let timerBurnInMove = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	@State var clockSynced = false
	
	@State var isShowingSettingsButton = false
	@State var isShowingSettingsView = false
	
	let fontSizeTimePortrait: CGFloat = 110
	let fontSizeAmPmPortriat: CGFloat = 40
	let fontSizeTimeLandscape:  CGFloat = 225
	let fontSizeAmPmLandscape:  CGFloat = 75
	@State var fontSizeTime: CGFloat = 0
	@State var fontSizeAmPm: CGFloat = 0
	
	var body: some View {
		ZStack {
			HStack {
				Text(timeString)
					.font(.system(size: fontSizeTime))
				Text(amPmString)
					.font(.system(size: fontSizeAmPm))
			}
			.padding()
			.offset(CGSize(width: offset, height: offset))
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
				updateClock()
				showSettingsButton()
			}
			.onReceive(timerClock) { time in
				syncClock()
			}
			.onReceive(timerBurnInMove) { time in
				offset = Int.random(in: -maxOffset...maxOffset)
			}
			.onTapGesture {
				showSettingsButton()
			}
			.sheet(isPresented: $isShowingSettingsView) {
				SettingsView()
			}
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
				updateOrientation()
			}
			
			if isShowingSettingsButton {
				VStack {
					HStack {
						Spacer()
						Button(action: {
							isShowingSettingsView = true
						}, label: {
							Image(systemName: "gearshape")
								.resizable()
								.frame(width: 25, height: 25)
								.foregroundColor(colorScheme == .light ? .black : .white)
								.background(colorScheme == .light ? .white : .black)
								.opacity(opacity)
						})
						.padding()
					}
					Spacer()
				}
			}
		}
		// This content shape and geture are needed to make the gesutre work over the whole display.
		.contentShape(Rectangle())
		.gesture(DragGesture(minimumDistance: 1)
			.onChanged({ gesture in
				opacity = 1.0 - gesture.location.y / UIScreen.main.bounds.height
			})
		)
	}
	
	// MARK: Functions
	
	func updateOrientation() {
		switch UIDevice.current.orientation {
		case .portrait, .portraitUpsideDown:
			fontSizeTime = fontSizeTimePortrait
			fontSizeAmPm = fontSizeAmPmPortriat
		case .landscapeLeft, .landscapeRight:
			fontSizeTime = fontSizeTimeLandscape
			fontSizeAmPm = fontSizeAmPmLandscape
		default:
			fontSizeTime = fontSizeTimePortrait
			fontSizeAmPm = fontSizeAmPmPortriat
		}
	}
	
	func syncClock() {
		updateClock()
		// When synced to the minute then only update eveyr miinute
		if !clockSynced {
			let dateFormatter = DateFormatter()
			dateFormatter.locale = Locale(identifier: "en_US")
			dateFormatter.dateFormat = "ss"
			let seconds = dateFormatter.string(from: Date())
			if seconds == "00" {
				updateClock()
				clockSynced = true
				timerClock = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
			}
		}
	}
	
	func updateClock() {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US")
		
		dateFormatter.dateFormat = "h:mm"
		timeString = dateFormatter.string(from: Date())
		
		dateFormatter.dateFormat = "a"
		amPmString = dateFormatter.string(from: Date())
	}
	
	func showSettingsButton() {
		Task {
			isShowingSettingsButton = true
			try? await Task.sleep(for: .seconds(15))
			isShowingSettingsButton = false
		}
	}
}

#Preview {
	CurrentTimeView()
}
