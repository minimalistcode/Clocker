//
//  SettingsView.swift
//  Clocker
//
//  Created by Jeff Zacharias on 7/22/23.
//  Copyright © 2023 Minimalist Code LLC. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
	@Environment(\.colorScheme) private var colorScheme
	
	var body: some View {
		ZStack {
			Rectangle()
				.foregroundColor(colorScheme == .light ? .white : .black)
			AboutView()
		}
	}
}

#Preview {
	SettingsView()
}
