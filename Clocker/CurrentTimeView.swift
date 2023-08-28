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
// - Moves evey minute to prevent burn in

import SwiftUI
import Combine
import OSLog

struct CurrentTimeView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.scenePhase) private var scenePhase
	@AppStorage("opacity") var opacity: Double = 1.0
	
	// Brightness
	private let opacityMaximum = 1.0
	private let opacityMinimum = 0.05
	private let opacityIncrement = 0.01
	
	// Settings
	@State var isShowingSettingsButton = false
	var settingsButtonDisplaySeconds = 5
	@State var isShowingSettingsView = false
	
	// Font
	let fontSizeTimePortrait: CGFloat = 110
	let fontSizeAmPmPortriat: CGFloat = 40
	let fontSizeTimeLandscape: CGFloat = 225
	let fontSizeAmPmLandscape: CGFloat = 75
	@State var fontSizeTime: CGFloat
	@State var fontSizeAmPm: CGFloat
	
	// Date Format
	private var dateFormatterTime = DateFormatter()
	private var dateFormatterAmPm = DateFormatter()
	@State var timeString: String = ""
	@State var amPmString: String = ""
	
	// Burn In
	@State var locationY: CGFloat = 0
	private let maxOffset = 25
	@State var offset = 0
	
	// Timer
	@State var cancellables = Set<AnyCancellable>()
	private let timerInterval = 0.1
	
	init() {
		_fontSizeTime = State(initialValue: fontSizeTimePortrait)
		_fontSizeAmPm = State(initialValue: fontSizeAmPmPortriat)
		dateFormatterTime.dateFormat = "h:mm"
		dateFormatterAmPm.dateFormat = "a"
	}
	
	var body: some View {
		ZStack {
			Rectangle().foregroundColor(.clear) // Need for gesture to work on whole display
			VStack {
				HStack {
					Text(timeString)
						.font(.system(size: fontSizeTime))
					Text(amPmString)
						.font(.system(size: fontSizeAmPm))
				}
			}
			.padding()
			.offset(CGSize(width: offset, height: offset))
			.opacity(opacity)
			.foregroundColor(colorScheme == .light ? .black : .white)
			.background(colorScheme == .light ? .white : .black)
			.preferredColorScheme(.dark)
			.statusBarHidden((isShowingSettingsButton || isShowingSettingsView) ? false : true)
			.persistentSystemOverlays(.hidden)
			.onAppear {
				updateOrientation()
				showSettingsButton()
				// Keep the display on all the time
				UIApplication.shared.isIdleTimerDisabled = true
				// Timer to update the time and move the time to prevent burn in.
				Timer
					.publish(every: timerInterval, on: .main, in: .default)
					.autoconnect()
					.sink(receiveCompletion: { _ in }, receiveValue: { date in
						let timeStringOld = timeString
						let currentDate = Date()
						timeString = dateFormatterTime.string(from: currentDate)
						amPmString = dateFormatterAmPm.string(from: currentDate)
						if timeStringOld != timeString {
							self.offset = Int.random(in: -self.maxOffset...self.maxOffset)
						}
					})
					.store(in: &cancellables)
			}
			.onChange(of: scenePhase) { newPhase in
				if newPhase == .active {
					showSettingsButton()
				}
			}
			.sheet(isPresented: $isShowingSettingsView) {
				InfoView()
			}
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
				updateOrientation()
			}
			if isShowingSettingsButton {
				SettingsButtonView(isShowingSettingsView: $isShowingSettingsView)
			}
		}
		// This content shape and geture are needed to make the gesutre work over the whole display.
		.contentShape(Rectangle())
		.gesture(DragGesture(minimumDistance: 1, coordinateSpace: .local)
			.onChanged { value in
				// Swipe up
				if value.location.y < locationY {
					opacity = opacity >= opacityMaximum ? opacityMaximum : opacity + opacityIncrement
				}
				// Swipe down
				else {
					opacity = opacity <= opacityMinimum ? opacityMinimum : opacity - opacityIncrement
				}
				locationY = value.location.y
			})
		.onTapGesture {
			showSettingsButton()
		}
	}
	
	// MARK: SettingsButtonView
	
	struct SettingsButtonView: View {
		@Environment(\.colorScheme) private var colorScheme
		@Binding var isShowingSettingsView: Bool
		
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
					})
					.padding()
				}
				Spacer()
				Text("Swipe up/down to adjust brightness")
			}
		}
	}
	
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
