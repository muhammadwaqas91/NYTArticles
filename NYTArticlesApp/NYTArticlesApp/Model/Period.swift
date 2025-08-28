//
//  Period.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

enum Period: Int, CaseIterable {
	case oneDay = 1
	case sevenDays = 7
	case thirtyDays = 30
	
	var title: String {
		switch self {
		case .oneDay:
			return "1D"
		case .sevenDays:
			return "7D"
		case .thirtyDays:
			return "30D"
		}
	}
}

enum ShareType: String {
	case facebook
}
