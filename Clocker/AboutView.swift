//
//  AboutView.swift
//  Clocker
//
//  Created by Jeff Zacharias on 7/22/23.
//  Copyright © 2023 Minimalist Code LLC. All rights reserved.
//

import SwiftUI

struct AboutView: View {
	private let copyrightString = "Copyright 2023 Minimalist Code LLC\nAll rights reserved."
	private let buildString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
	private let versionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	private let imageSize: CGSize = CGSize(width: 125, height: 125)
	private let details: String
	private var appName: String
	
	init() {
		appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
		details = "Version \(versionString)\n\(copyrightString)"
	}
	
	var body: some View {
		ScrollView {
			Spacer(minLength: 50)
			Image("AppLogo")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: imageSize.width, height: imageSize.height, alignment: .center)
				.clipShape(Rectangle())
			Spacer(minLength: 25)
			Text(appName).font(.title2)
			Spacer(minLength: 25)
			Text(details)
			.multilineTextAlignment(.center)
		}
		.font(.body)
	}
}


#Preview {
	AboutView()
}

