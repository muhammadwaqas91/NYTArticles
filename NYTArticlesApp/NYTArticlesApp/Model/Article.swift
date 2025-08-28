//
//  Article.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

struct Article: Identifiable, Decodable {
	let id: Int
	let title: String
	let byline: String?
	let publishedDate: String
	let url: String

	enum CodingKeys: String, CodingKey {
		case id, title, byline, url
		case publishedDate = "published_date"
	}
}
