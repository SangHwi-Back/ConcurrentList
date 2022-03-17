//
//  CurrencyFirstViewController.swift
//  ConcurrentMovieList
//
//  Created by 백상휘 on 2022/03/09.
//

import UIKit

class CurrencyFirstViewController: UIViewController {

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
        
        if isReload {
            fetchDataResults.removeAll()
        }
        
        networkModel.sendRequest(from: fetchDataResults.count+1, to: fetchDataResults.count+10) { [weak self] culturalData in
            guard let self = self else { return }
            guard let culturalData = culturalData else { return }
            self.fetchDataResults.append(contentsOf: culturalData)
        }
    }
}

extension CurrencyFirstViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchDataResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CustomTableViewCell else {
            LoggerUtil.faultLog(message: "DequereusableCell initialize failed from ConcurrencyFirstViewController")
            return UITableViewCell()
        }

        let model = self.fetchDataResults[indexPath.row]

        cell.delegate = self
        cell.numberLabel.text = "\(indexPath.row)"

        cell.indexPath = indexPath

        DispatchQueue.global(qos: .userInitiated).async {
            var image: UIImage?
            if let url = URL(string: model.MAIN_IMG), let data = try? Data(contentsOf: url) {
                image = UIImage(data: data)
            }

            DispatchQueue.main.async {
                if let image = image {
                    cell.cellImageView.image = image
                }
                cell.cellWebView.loadHTMLString(model.FAC_DESC, baseURL: nil)
            }
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

extension CurrencyFirstViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == fetchDataResults.count-1 {
            fetchRequest()
        }
    }
}

extension CurrencyFirstViewController: CustomCellSizeDelegate {
    func customCellDidFinishLoad(using height: CGFloat, at indexPath: IndexPath) {
        guard let cell = currencyTableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        
        currencyTableView.beginUpdates()
        preDefinedRowHeights.updateValue(Float(cell.cellImageView.frame.height+height/2), forKey: indexPath)
        currencyTableView.endUpdates()
    }
}
