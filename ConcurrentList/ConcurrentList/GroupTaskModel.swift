//
//  GroupTaskModel.swift
//  ConcurrentList
//
//  Created by 백상휘 on 2022/03/14.
//

import Foundation
import UIKit

class GroupTaskModel<T: UITableViewCell> {
    
    private var group = DispatchGroup()
    private var concurrentQueue: DispatchQueue
    
    init(qos: DispatchQoS) {
        self.concurrentQueue = DispatchQueue(label: "customCellQueue", qos: qos, attributes: .concurrent)
    }
    
    @discardableResult
    func processConcurrentImage(target: T, urlString: String, _ completionHandler: @escaping (T, Data)->Void) -> DispatchWorkItem {
        let item = DispatchWorkItem {
            if let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
                completionHandler(target, data)
            }
        }
        
        concurrentQueue.async(group: group, execute: item)
        return item
    }
    
    @discardableResult
    func processConcurrent(target: T, _ completionHandler: @escaping (T)->Void) -> DispatchWorkItem {
        let item = DispatchWorkItem(flags: .barrier) {
            completionHandler(target)
        }
        
        concurrentQueue.async(group: group, execute: item)
        return item
    }
    
    @discardableResult
    func processSerial(target: T, _ completionHandler: @escaping (T)->Void) -> DispatchWorkItem {
        let item = DispatchWorkItem {
            DispatchQueue.main.async(group: self.group) {
                completionHandler(target)
            }
        }
        
        concurrentQueue.async(group: group, execute: item)
        return item
    }
    
    func notifyCustomCellGroup(target: T, _ completionHandler: @escaping (T)->Void) {
        group.notify(queue: .main) {
            completionHandler(target)
        }
    }
    
    func waitTimeoutCustomCellGroup(target: T, timeoutHandler: ((T)->Void)?, _ completionHandler: @escaping (T)->Void) {
        if group.wait(timeout: .now()+5) == .timedOut {
            if let timeoutHandler = timeoutHandler {
                timeoutHandler(target)
            }
            
            return
        }
        
        completionHandler(target)
    }
}
