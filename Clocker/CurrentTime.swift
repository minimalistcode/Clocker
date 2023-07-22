//
//  CurrentTime.swift
//  Clocker
//
//  Created by Jeff Zacharias on 7/22/23.
//

// Features
// Update every minute
// Dark always
// Dim with swipe up/down
// Move evey move to prevent burn in

import SwiftUI


struct CurrentTime: View {
	@Environment(\.colorScheme) private var colorScheme
	@State var timeString = ""
	@State var amPmString = ""
	@State var offset = 0
	let maxOffset = 25
	let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	
	var body: some View {
		HStack {
			Spacer()
			Text(timeString)
				.font(.system(size: 225))
			Text(amPmString)
				.font(.system(size: 75))
		}
		.padding()
		.offset(CGSize(width: offset, height: offset))
		.foregroundColor(colorScheme == .light ? .black : .white)
		.background(colorScheme == .light ? .white : .black)
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
	CurrentTime()
}
