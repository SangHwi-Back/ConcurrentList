//
//  BookStorePopInfo.swift
//  ConcurrentMovieList
//
//  Created by 백상휘 on 2022/03/09.
//

import Foundation

struct BookStorePopInfo: Codable {
    var list_total_count: Int
    var RESULT: RESULT
    var row: [JSObject]
}
