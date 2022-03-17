//
//  ConcurrentMovieListTests.swift
//  ConcurrentMovieListTests
//
//  Created by 백상휘 on 2022/03/08.
//

import XCTest
@testable import ConcurrentList
import WebKit

let module = APISessionModel()
let dispatchModel = GroupTaskModel(qos: .userInitiated)
var modelData = [SpaceInfo]()
let cell = UITableViewCell()
let imageView = UIImageView()
let webScreen = WKWebView()

var time: Double = 0

class ConcurrentListTests: XCTestCase, WKUIDelegate, WKNavigationDelegate {
    
    override class func setUp() {
        module.sendRequest(from: 1, to: 10) { results in
            guard let results = results else { XCTFail(); return }
            modelData.append(contentsOf: results)
        }
        
        cell.addSubview(imageView)
        cell.addSubview(webScreen)
        
        cell.frame.size = CGSize(width: 300, height: 150)
        
        imageView.frame.size = CGSize(width: 120, height: 120)
        imageView.center.x = cell.center.x
        imageView.frame.origin.y = 0
        
        webScreen.frame = CGRect(x: 0, y: imageView.frame.maxY+12, width: cell.frame.width, height: 10)
        webScreen.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 0).isActive = true
    }
    
    func testCurrency() {
        webScreen.uiDelegate = self
        webScreen.navigationDelegate = self
        
        measure {
            for _ in 1...100 {
                for (inx, data) in modelData.enumerated() {
                    var image: UIImage?
                    dispatchModel.processConcurrentImage(urlString: data.MAIN_IMG) {
                        if let testImage = UIImage(data: $0) {
                            image = testImage
                        } else {
                            LoggerUtil.debugLog(message: "\(inx) index image nil")
                        }
                    }
                    dispatchModel.processSerial {
                        imageView.image = image
                    }
                    dispatchModel.notifyCustomCellGroup {
                        webScreen.loadHTMLString(data.FAC_DESC, baseURL: nil)
                    }
                }
            }
        }
    }
    
    func testNoneCurrency() {
        webScreen.uiDelegate = self
        webScreen.navigationDelegate = self
        
        measure {
            for _ in 1...100 {
                for contentsData in modelData {
                    if
                        let url = URL(string: contentsData.MAIN_IMG),
                        let data = try? Data(contentsOf: url),
                        let image = UIImage(data: data)
                    {
                        imageView.image = image
                        webScreen.loadHTMLString(contentsData.FAC_DESC, baseURL: nil)
                    }
                }
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView.isLoading == false else { return }
        webView.evaluateJavaScript("document.body.scrollHeight") { (result, error) in
            guard type(of: result.self) == CGFloat.self else { return }
            Thread.sleep(forTimeInterval: 1)
        }
    }
}
