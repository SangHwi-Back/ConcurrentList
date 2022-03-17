//
//  CurrencySecondViewController.swift
//  ConcurrentMovieList
//
//  Created by 백상휘 on 2022/03/09.
//

import UIKit

class CurrencySecondViewController: UIViewController {

    private let refreshControl = UIRefreshControl()
    private var networkModel = APISessionModel()
    private var fetchDataResults = [SpaceInfo]() {
        didSet {
            DispatchQueue.main.async {
                self.currencyTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    private let identifier = String(describing: CustomTableViewCell.self)
    private var preDefinedRowHeights = [IndexPath: Float]()
    private let groupCellTaskModel = GroupTaskModel(qos: .userInteractive)
    
    @IBOutlet weak var currencyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: identifier, bundle: nil)
        currencyTableView.register(nib, forCellReuseIdentifier: identifier)
        currencyTableView.dataSource = self
        currencyTableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshTableView(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            currencyTableView.refreshControl = refreshControl
        } else {
            currencyTableView.addSubview(refreshControl)
        }
        
        fetchRequest()
    }
    
    @objc func refreshTableView(_ sender: Any) {
        fetchRequest(isReload: true)
    }
    
    func fetchRequest(isReload: Bool = false) {
        
        if isReload { fetchDataResults.removeAll() }
        
        networkModel.sendRequest(from: fetchDataResults.count+1, to: fetchDataResults.count+10) { [weak self] culturalData in
            guard let self = self, let culturalData = culturalData else { return }
            self.fetchDataResults.append(contentsOf: culturalData)
        }
    }
}

extension CurrencySecondViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchDataResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CustomTableViewCell else {
            LoggerUtil.faultLog(message: "DequereusableCell initialize failed from ConcurrencySecondViewController")
            return UITableViewCell()
        }
        
        let model = fetchDataResults[indexPath.row]
        
        cell.delegate = self
        cell.numberLabel.text = "\(indexPath.row)"
        
        cell.htmlString = model.FAC_DESC
        cell.indexPath = indexPath
        
        let imageTask = groupCellTaskModel.processConcurrentImage(target: cell, urlString: model.MAIN_IMG) { target, data in
            guard let target = target as? CustomTableViewCell else { return }
            target.cellImage = UIImage(data: data)
        }
        groupCellTaskModel.processConcurrent(target: cell) { target in
            if let target = target as? CustomTableViewCell, let image = target.cellImage {
                imageTask.cancel()
            }
        }
        let someSerialTask = groupCellTaskModel.processSerial(target: cell) { target in
            guard let target = target as? CustomTableViewCell else { return }
            target.cellImageView.image = target.cellImage
        }
        groupCellTaskModel.notifyCustomCellGroup(target: cell) { target in
            guard let target = target as? CustomTableViewCell, let htmlString = target.htmlString else {
                someSerialTask.cancel()
                return
            }
            target.cellWebView.loadHTMLString(htmlString, baseURL: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard fetchDataResults.count-1 >= indexPath.row, let rowHeight = preDefinedRowHeights[indexPath] else {
            return UITableView.automaticDimension
        }
        return CGFloat(rowHeight)
    }
}

extension CurrencySecondViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == fetchDataResults.count-1 {
            fetchRequest()
        }
    }
}

extension CurrencySecondViewController: CustomCellSizeDelegate {
    func customCellDidFinishLoad(using height: CGFloat, at indexPath: IndexPath) {
        guard let cell = currencyTableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        
        currencyTableView.beginUpdates()
        preDefinedRowHeights.updateValue(Float(cell.cellImageView.frame.height+height/2), forKey: indexPath)
        currencyTableView.endUpdates()
    }
}
