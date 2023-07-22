//
//  CurrentTime.swift
//  Clocker
//
//  Created by Jeff Zacharias on 7/22/23.
//

// Features
// Update every minute
// Dim with swipe up/down
// Move evey move to prevent burn in

import SwiftUI


struct CurrentTimeView: View {
	@Environment(\.colorScheme) private var colorScheme
	@State var timeString = ""
	@State var amPmString = ""
	@State var offset = 0
	let maxOffset = 25
	let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	@AppStorage("opacity") var opacity: Double = 1.0

	
	var body: some View {
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
		}
		.onReceive(timer) { time in
			updateClock()
			offset = Int.random(in: -maxOffset...maxOffset)
			print(offset)
		}
		.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
			.onChanged({ value in
				opacity = 1.0 - value.location.y / UIScreen.main.bounds.height
			}))
	}
		
	func updateClock() {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US")
		
		dateFormatter.dateFormat = "H:mm"
		timeString = dateFormatter.string(from: Date())
		
		dateFormatter.dateFormat = "a"
		amPmString = dateFormatter.string(from: Date())
	}
}

#Preview {
	CurrentTimeView()
}
