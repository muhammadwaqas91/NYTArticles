//
//  MostPopularArticleCategory.swift
//  NYTArticlesApp
//
//  Created by Muhammad Waqas on 28/08/25.
//

import Foundation

enum MostPopularArticleCategory: String, CaseIterable {
	
	case viewed, emailed, shared
	
	var title: String {
		switch self {
		case .viewed:
			return "Most Viewed"
		case .emailed:
			return "Most Emailed"
		case .shared:
			return "Most Shared"
		}
	}
}
