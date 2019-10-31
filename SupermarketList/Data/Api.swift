//
//  Api.swift
//  SupermarketList
//
//  Created by Marlon Morato on 24/10/19.
//  Copyright © 2019 Marlon Burnett. All rights reserved.
//

import Foundation

typealias ListCompletionHandler = (Error?,[Item]?) -> ()
typealias CreateItemCompletionHandler = (Error?,Item?) -> ()
typealias EmptyCompletionHandler = (Error?) -> ()

let LIST_ENDPOINT = "https://meetups.azurewebsites.net/api/ListHttpTrigger?code=joi5GflrhcSPiFWnNXKPJ6zN06gZqotbh114kxZb5pvlNDiX3i8hGg=="
let CREATE_ENDPOINT = "https://meetups.azurewebsites.net/api/CreateHttpTrigger?code=Pu74Mk9ZaKWyM7EbEfsA1Gh1RN0ckoHYXyifKLDgwVfTa2p7a9b81A=="
let DELETE_ENDPOINT = "https://meetups.azurewebsites.net/api/DeleteHttpTrigger?code=telPaWl/Iba6o5r/U6zRro3mtsZSQjMiP7E0cCi6RSIG2DvgwC9gjA=="


protocol ApiContract {
    func fetchList(completionHandler: @escaping ListCompletionHandler)
    func createItem(value: String, completionHandler: @escaping CreateItemCompletionHandler)
    func delete(item: Item, completionHandler: @escaping EmptyCompletionHandler)
}

class Api: ApiContract {
    static let shared = Api()
    
    private let session = URLSession.shared
    
    private init() {}
    
    func fetchList(completionHandler: @escaping ListCompletionHandler) {
        let url =  URL(string: LIST_ENDPOINT)!
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completionHandler(error, nil)
                return
            }
            
            guard let data = data, let items = try? JSONDecoder().decode([Item].self, from: data) else {
                completionHandler(NSError(domain: "br.com.iteris.meetups", code: 0, userInfo: nil), nil)
                return
            }
            
            completionHandler(nil,items)
            return
        }
        
        task.resume()
    }
    
    func createItem(value: String, completionHandler: @escaping CreateItemCompletionHandler) {
        let url = URL(string: CREATE_ENDPOINT)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json = ["value":value]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            if let error = error {
                completionHandler(error, nil)
                return
            }
            
            guard let data = data, let item = try? JSONDecoder().decode(Item.self, from: data) else {
                completionHandler(NSError(domain: "br.com.iteris.meetups", code: 0, userInfo: nil), nil)
                return
            }
            
            completionHandler(nil,item)
        }
        
        task.resume()
    }
    
    func delete(item: Item, completionHandler: @escaping EmptyCompletionHandler) {
        let url = URL(string: DELETE_ENDPOINT)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json = ["id":item.id]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            if let error = error {
                completionHandler(error)
                return
            }
            
            completionHandler(nil)
        }
        
        task.resume()
    }
}
