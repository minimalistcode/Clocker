//
//  InfoView.swift
//  Clocker
//
//  Created by Jeff Zacharias on 7/22/23.
//  Copyright © 2023 Minimalist Code LLC. All rights reserved.
//

import SwiftUI

struct InfoView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		ZStack {
			Rectangle()
				.foregroundColor(colorScheme == .light ? .white : .black)
			AboutView()
			VStack {
				HStack {
					Spacer()
					Button(action: {
						dismiss()
					}, label: {
						Image(systemName: "x.circle")
							.resizable()
							.frame(width: 25, height: 25)
							.foregroundColor(colorScheme == .light ? .black : .white)
							.background(colorScheme == .light ? .white : .black)
					})
					.padding()
				}
				Spacer()
			}
		}
	}
}

#Preview {
	InfoView()
}
