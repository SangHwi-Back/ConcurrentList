//
//  APISessionModel.swift
//  ConcurrentMovieList
//
//  Created by 백상휘 on 2022/03/09.
//

import Foundation

class APISessionModel {
    
    private let apiKey = "" // your own api-key
    private var qualifiedURLString = ""
    private var baseURL = URL(string: "http://openapi.seoul.go.kr:8088/")
    private let decoder = JSONDecoder()
    
    private var session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    private var pathComponents: [String] {
        return [apiKey, "json", "culturalSpaceInfo"]
    }
    
    // 서울시 문화공간 정보
    func sendRequest(from: Int, to: Int, completionHandler: @escaping (([SpaceInfo]?)->Void)) {
        
        guard var url = baseURL else { return }
        
        for comp in pathComponents {
            url.appendPathComponent(comp)
        }
        url.appendPathComponent("\(from)")
        url.appendPathComponent("\(to)")
        
        let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                LoggerUtil.faultLog(message: "Error Occured! \(String(describing: error))")
                return
            }
            guard let data = data else {
                LoggerUtil.debugLog(message: "Look this data: \(data)")
                completionHandler(nil)
                return
            }
            guard response?.mimeType == MimeType.applicationJson else {
                LoggerUtil.debugLog(message: "Look this mimeType: \(response?.mimeType ?? "nothing passed")")
                completionHandler(nil)
                return
            }
            
            let result = try? self.decoder.decode(MasterJSON.self, from: data)
            
            if let param = result?.culturalSpaceInfo.row {
                completionHandler(param)
            }
        }
        
        DispatchQueue.global(qos: .utility).async {
            task.resume()
        }
    }
    
    enum MimeType: String, Equatable {
        case applicationJson = "application/json"
        
        static func ==(lhs: MimeType, rhs: String?) -> Bool {
            lhs.rawValue.lowercased() == rhs?.lowercased()
        }
        
        static func ==(lhs: String?, rhs: MimeType) -> Bool {
            lhs?.lowercased() == rhs.rawValue.lowercased()
        }
    }
    
}
