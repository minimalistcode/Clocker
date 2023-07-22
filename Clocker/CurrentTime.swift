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
	let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	
	var body: some View {
		HStack {
			Spacer()
			Text(timeString)
				.font(.system(size: 250))
			Text(amPmString)
				.font(.system(size: 75))
		}
		.foregroundColor(colorScheme == .light ? .black : .white)
		.background(colorScheme == .light ? .white : .black)
		.onAppear {
			updateClock()
		}
		.onReceive(timer) { time in
			updateClock()
			print(Date())
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
