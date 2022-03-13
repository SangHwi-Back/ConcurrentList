//
//  NoneViewController.swift
//  ConcurrentMovieList
//
//  Created by 백상휘 on 2022/03/09.
//

import UIKit

class NoneViewController: UIViewController {
    
    private let refreshControl = UIRefreshControl()
    private var networkModel: APISessionModel = APISessionModel()
    private var fetchDataResults = [SpaceInfo]() {
        didSet {
            DispatchQueue.main.async {
                self.noneTableView.reloadData()
            }
        }
    }
    private var isEnableRefresh = true
    private let identifier = String(describing: CustomTableViewCell.self)
    
    @IBOutlet weak var noneTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: identifier, bundle: nil)
        noneTableView.register(nib, forCellReuseIdentifier: identifier)
        noneTableView.dataSource = self
        noneTableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshTableView(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            noneTableView.refreshControl = refreshControl
        } else {
            noneTableView.addSubview(refreshControl)
        }
        
        fetchRequest()
    }
    
    @objc func refreshTableView(_ sender: Any) {
        fetchRequest()
    }
    
    func fetchRequest(isReload: Bool = false) {
        
        guard isEnableRefresh else { return }
        
        if isReload {
            fetchDataResults.removeAll()
        }
        
        networkModel.sendRequest(from: fetchDataResults.count+1, to: fetchDataResults.count+10) { [weak self] culturalData in
            guard let self = self else { return }
            guard let culturalData = culturalData else { self.isEnableRefresh.toggle(); return }
            self.fetchDataResults.append(contentsOf: culturalData)
        }
    }
}

extension NoneViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchDataResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        let model = fetchDataResults[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        cell.preDefinedRowHeight = model.rowHeight
        
        cell.cellImageView.image = UIImage(systemName: "nosign")
        if let url = URL(string: model.MAIN_IMG), let data = try? Data(contentsOf: url) {
            cell.cellImageView.image = UIImage(data: data)
        }
        
        cell.cellWebView.pageZoom = 2
        cell.cellWebView.loadHTMLString(model.FAC_DESC, baseURL: nil)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else {
            return UITableView.automaticDimension
        }
        
        let rowHeight = fetchDataResults[indexPath.row].rowHeight ?? cell.preDefinedRowHeight
        
        if let rowHeight = rowHeight {
            return CGFloat(rowHeight)
        } else {
            return UITableView.automaticDimension
        }
    }
}

extension NoneViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard isEnableRefresh else { return }
        if indexPath.row == fetchDataResults.count-1 {
            fetchRequest()
        }
    }
}

extension NoneViewController: CustomCellSizeDelegate {
    func customCellDidFinishLoad(using height: CGFloat, at indexPath: IndexPath) {
        guard
            fetchDataResults[indexPath.row].rowHeight == nil,
            let cell = noneTableView.cellForRow(at: indexPath) as? CustomTableViewCell
        else {
            return
        }

        noneTableView.beginUpdates()
        cell.cellWebView.heightAnchor.constraint(greaterThanOrEqualToConstant: height/2).isActive = true
        cell.setNeedsLayout()
        cell.setNeedsDisplay()
        noneTableView.endUpdates()
    }
}
