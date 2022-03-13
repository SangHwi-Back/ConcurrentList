//
//  LoggerUtil.swift
//  ConcurrentMovieList
//
//  Created by 백상휘 on 2022/03/13.
//

import Foundation
import os.log

class LoggerUtil {
    
    static let subsystem = Bundle.main.bundleIdentifier!
    
    static func debugLog(message: String) {
        Logger(subsystem: subsystem, category: "CurrencyDebug").debug("\(message)")
    }
    
    static func errorLog(message: String) {
        Logger(subsystem: subsystem, category: "CurrencyError").error("\(message)")
    }
    
    static func faultLog(message: String) {
        Logger(subsystem: subsystem, category: "CurrencyFault").fault("\(message)")
    }
    
}
