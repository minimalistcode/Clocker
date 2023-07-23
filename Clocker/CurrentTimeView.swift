//
//  CurrentTimeView.swift
//  Clocker
//
//  Created by Jeff Zacharias on 7/22/23.
//  Copyright © 2023 Minimalist Code LLC. All rights reserved.
//

// Features
// Update every minute
// Dim with swipe up/down
// Move evey move to prevent burn in

import SwiftUI


struct CurrentTimeView: View {
	@Environment(\.colorScheme) private var colorScheme
	@AppStorage("opacity") var opacity: Double = 1.0
	@State var timeString = ""
	@State var amPmString = ""
	@State var offset = 0
	let maxOffset = 25
	let timerClockUodate = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let timerBurnInMove = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	@State var isShowingSettingsButton = false
	@State var isShowingSettingsView = false
	
	var body: some View {
		ZStack {
			HStack {
				Group {
					Text(timeString)
						.font(.system(size: 225))
					Text(amPmString)
						.font(.system(size: 75))
				}
				.opacity(opacity)
			}
			.padding()
			.offset(CGSize(width: offset, height: offset))
			.foregroundColor(colorScheme == .light ? .black : .white)
			.background(colorScheme == .light ? .white : .black)
			.preferredColorScheme(.dark)
			.onAppear {
				// Keep the display on all the time
				UIApplication.shared.isIdleTimerDisabled = true
				updateClock()
				showSettingsButton()
			}
			.onReceive(timerClockUodate) { time in
				updateClock()
			}
			.onReceive(timerBurnInMove) { time in
				offset = Int.random(in: -maxOffset...maxOffset)
			}
			.onTapGesture {
				showSettingsButton()
			}
			.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
				.onChanged({ value in
					opacity = 1.0 - value.location.y / UIScreen.main.bounds.height
				}))
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
			if isShowingSettingsView {
				SettingsView()
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
			Thread.sleep(forTimeInterval: 15)
			isShowingSettingsButton = false
		}
	}
}

#Preview {
	CurrentTimeView()
}
