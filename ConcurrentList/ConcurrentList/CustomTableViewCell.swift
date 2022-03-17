//
//  CustomTableViewCell.swift
//  ConcurrentMovieList
//
//  Created by 백상휘 on 2022/03/12.
//

import UIKit
import WebKit

protocol CustomCellSizeDelegate {
    func customCellDidFinishLoad(using height: CGFloat, at indexPath: IndexPath)
}

class CustomTableViewCell: UITableViewCell, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet var cellImageView: UIImageView!
    @IBOutlet var cellWebView: WKWebView!
    
    var delegate: CustomCellSizeDelegate?
    var indexPath: IndexPath?
    var htmlString: String?
    var cellImage: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellWebView.uiDelegate = self
        cellWebView.navigationDelegate = self
        cellWebView.scrollView.isScrollEnabled = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView.isLoading == false else { return }
        evaluateHeightUsingJavaScript(webView)
    }
    
    func evaluateHeightUsingJavaScript(_ webView: WKWebView) {
        webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] (result, error) in
            guard let self = self else { return }
            guard let height = result as? CGFloat, let indexPath = self.indexPath else { return }
            
            self.delegate?.customCellDidFinishLoad(using: (height > 300 ? 300 : height), at: indexPath)
        }
    }
}
