//
//  ClockSync.swift
//  Clocker
//
//  Created by Jeff Zacharias on 7/26/23.
//  Copyright © 2023 Minimalist Code LLC. All rights reserved.
//

import SwiftUI

class ClockSync: ObservableObject {
	@Published var timeString: String = ""
	@Published var amPmString: String = ""
	@Published var currentDate: Date = Date()
	@Published var offset = 0
	private let maxOffset = 25

	init() {
		updateClock()
		// Set a timer to start and the start of the next minute
		let hour = Calendar.current.component(.hour, from: currentDate)
		let minute = Calendar.current.component(.minute, from: currentDate)
		// Adjust for minute bounday
		let nextMinute = minute < 59 ? minute + 1 : 0
		let nextHour = minute < 59 ? hour : hour + 1
		let currentDateMinute: Date = Calendar.current.date(bySettingHour: nextHour, minute: nextMinute, second: 0, of: currentDate)!
		let timeIntervalDifference = currentDate.distance(to: currentDateMinute)
		let nextMinuteDate = Date.init(timeIntervalSinceNow: timeIntervalDifference)
		// Set a timer to fire at every minute on the minute
		let timer = Timer(fire: nextMinuteDate, interval: 60.0, repeats: true) { time in
			self.currentDate = Date()
			self.updateClock()
			self.offset = Int.random(in: -self.maxOffset...self.maxOffset)
		}
		RunLoop.main.add(timer, forMode: .default)
	}
	
	private func updateClock() {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US")
		
		dateFormatter.dateFormat = "h:mm"
		timeString = dateFormatter.string(from: currentDate)
		
		dateFormatter.dateFormat = "a"
		amPmString = dateFormatter.string(from: currentDate)
	}
}
