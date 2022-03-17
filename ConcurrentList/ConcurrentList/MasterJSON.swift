//
//  MasterJSON.swift
//  ConcurrentMovieList
//
//  Created by 백상휘 on 2022/03/09.
//

import Foundation

typealias JSObject = MasterJSON.BookStorePopInfo.JSObject
typealias SpaceInfo = MasterJSON.BookStorePopInfo.SpaceInfo

struct MasterJSON: Codable {
    var culturalSpaceInfo: BookStorePopInfo
    
    struct BookStorePopInfo: Codable {
        var list_total_count: Int
        var RESULT: RESULT
        var row: [SpaceInfo]
        
        struct JSObject: Codable {
            var UID_: Float
            var PART_CODE: String
            var PART_NAME: String
            var G_NAME: String
            var G_MAKER: String
            var PONGJEL_YN: String
            var G_PRICE: String
            var G_SIMPLE: String
            var PUBLIC_YEAR: String
            var PAGE_NUM: String
            var IMG_URL: String
            var G_SELL: String
        }
        
        struct SpaceInfo: Codable {
            var NUM: String
            var SUBJCODE: String
            var FAC_NAME: String
            var ADDR: String
            var X_COORD: String
            var Y_COORD: String
            var PHNE: String
            var FAX: String
            var HOMEPAGE: String
            var OPENHOUR: String
            var ENTR_FEE: String
            var CLOSEDAY: String
            var OPEN_DAY: String
            var SEAT_CNT: String
            var MAIN_IMG: String
            var ETC_DESC: String
            var FAC_DESC: String
            var ENTRFREE: String
            var SUBWAY: String
            var BUSSTOP: String
            var YELLOW: String
            var GREEN: String
            var BLUE: String
            var RED: String
            var AIRPORT: String
            
            var preDefinedRowHeight: Float?
        }
        
        struct RESULT: Codable {
            var CODE: String
            var MESSAGE: String
        }

    }
}
