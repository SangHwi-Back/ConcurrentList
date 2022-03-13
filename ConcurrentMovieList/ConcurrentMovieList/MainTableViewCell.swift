//
//  MainTableViewCell.swift
//  ConcurrentMovieList
//
//  Created by 백상휘 on 2022/03/09.
//

import UIKit
import WebKit

class MainTableViewCell: UITableViewCell, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellWebView: WKWebView!
    
    var webViewHeight: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellWebView.uiDelegate = self
        cellWebView.navigationDelegate = self
        cellWebView.pageZoom = 2
        cellWebView.scrollView.isScrollEnabled = false
        cellWebView.contentMode = .scaleAspectFill
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        guard webView.isLoading == false else { return }
        
        webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] (result, error) in
            guard let self = self else { return }
            if let height = result as? CGFloat {
                self.cellWebView.frame.size.height = height*2
                self.setNeedsLayout()
            }
        }
    }
    
    
}
