//
//  ContentView.swift
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

struct ContentView: View {
	@Environment(\.colorScheme) private var colorScheme
	
	var body: some View {
		HStack {
			Spacer()
			Text(currentTime())
				.font(.system(size: 250))
			Text(currentTimeAmPm())
				.font(.system(size: 75))
		}
		.foregroundColor(colorScheme == .light ? .black : .white)
		.background(colorScheme == .light ? .white : .black)
	}
}


func currentTime() -> String {
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "H:mm"
	dateFormatter.locale = Locale(identifier: "en_US")
	return dateFormatter.string(from: Date())
}

func currentTimeAmPm() -> String {
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "a"
	dateFormatter.locale = Locale(identifier: "en_US")
	return dateFormatter.string(from: Date())
}


#Preview {
    ContentView()
}
