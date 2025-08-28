//
//  ArticlesResponse.swift
//  RestAPIFramework
//
//  Created by Muhammad Waqas on 27/08/25.
//

import Foundation

struct ArticlesResponse: Decodable {
	let results: [Article]
}
