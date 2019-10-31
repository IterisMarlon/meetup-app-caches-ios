//
//  ViewModel.swift
//  SupermarketList
//
//  Created by Marlon Morato on 24/10/19.
//  Copyright © 2019 Marlon Burnett. All rights reserved.
//

import Foundation

class ViewModel {
    private var items: [Item] = []
    private var api: ApiContract
    private var cache: CacheContract
    
    init(api: ApiContract = Api.shared) {
        self.api = api
        self.cache = Cache()
    }
    
    func fetch(completionHandler: @escaping EmptyCompletionHandler) {
        cache.get(key: .items, type: [Item].self, fetch: api.fetchList) { (error, items) in
            guard let items = items else {
                completionHandler(error ?? NSError())
                return
            }
            
            self.items.removeAll()
            self.items.append(contentsOf: items)
            
            completionHandler(nil)
        }
    }
    
    func add(value: String, completionHandler: @escaping EmptyCompletionHandler) {
        api.createItem(value: value) { (error, item) in
            guard let item = item else {
                completionHandler(error ?? NSError())
                return
            }
            
            self.items.insert(item, at: 0)
            self.cache.put(item: self.items, in: .items)
            completionHandler(nil)
        }
    }
    
    func remove(at index: Int, completionHandler: @escaping EmptyCompletionHandler) {
        let item = items[index]
        
        api.delete(item: item) { (error) in
            guard let error = error else {
                self.items.remove(at: index)
                self.cache.put(item: self.items, in: .items)
                completionHandler(nil)
                return
            }
            
            completionHandler(error)
        }
    }
    
    func count() -> Int {
        return items.count
    }
    
    func item(at index: Int) -> Item {
        return items[index]
    }
}
