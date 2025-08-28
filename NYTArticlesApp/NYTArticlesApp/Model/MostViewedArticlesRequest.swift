//
//  MostViewedArticlesRequest.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation
import RestAPIFramework

enum MostPopularArticlesRequest: Requestable {
	
	typealias ResponseType = ArticlesResponse
	
	case viewed(period: Period)
	case emailed(period: Period)
	case shared(period: Period, shareType: ShareType)
	
	var baseURL: String { "https://api.nytimes.com/svc/mostpopular/v2" }
	
	var method: HTTPMethod { .GET }
	
	var path: String {
		switch self {
		case .viewed(let period):
			return "/viewed/\(period.rawValue).json"
		case .emailed(let period):
			return "/emailed/\(period.rawValue).json"
		case .shared(let period, let shareType):
			return "/shared/\(period.rawValue)/\(shareType.rawValue).json"
		}
	}
	var queryParameters: [String : String]? {
		return ["api-key": "Give_Your_API_Key_here"]
	}
}
