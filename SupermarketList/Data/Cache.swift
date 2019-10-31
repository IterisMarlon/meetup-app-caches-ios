//
//  Cache.swift
//  SupermarketList
//
//  Created by Marlon Morato on 24/10/19.
//  Copyright © 2019 Marlon Burnett. All rights reserved.
//

import Foundation

enum CacheKey: String {
    case items
}

struct CacheHolder<T: Codable> : Codable {
    let item: T
    let date: Date
    let timeToLive: TimeInterval
}

protocol CacheContract {
    func get<T: Codable>(key: CacheKey, type: T.Type, timeToLive: TimeInterval, fetch: (@escaping (Error?,T?) -> ()) -> (), completionHandler: @escaping (Error?,T?) -> ())
    func put<T: Codable>(item: T, in key: CacheKey, timeToLive: TimeInterval)
}

class Cache: CacheContract {
    private let defaults = UserDefaults.standard
    
    func get<T: Codable>(key: CacheKey, type: T.Type, timeToLive: TimeInterval, fetch: (@escaping (Error?,T?) -> ()) -> (), completionHandler: @escaping (Error?,T?) -> ()) {
        guard let json = defaults.string(forKey: key.rawValue), let data = json.data(using: .utf8), let holder = try? JSONDecoder().decode(CacheHolder<T>.self, from: data), Date() < holder.date.addingTimeInterval(holder.timeToLive) else {
            self.fetch(key: key, timeToLive: timeToLive, fetch: fetch, completionHandler: completionHandler)
            return
        }
        
        completionHandler(nil,holder.item)
    }
    
    func put<T: Codable>(item: T, in key: CacheKey, timeToLive: TimeInterval) {
        let holder = CacheHolder<T>(item: item, date: Date(), timeToLive: timeToLive)
        let data = try! JSONEncoder().encode(holder)
        let json = String(data: data, encoding: .utf8)!
        
        self.defaults.set(json, forKey: key.rawValue)
    }
    
    private func fetch<T: Codable>(key: CacheKey, timeToLive: TimeInterval, fetch: (@escaping (Error?,T?) -> ()) -> (), completionHandler: @escaping (Error?,T?) -> ()) {
        fetch { error, item in
            guard let item = item else {
                completionHandler(error ?? NSError(),nil)
                return
            }
            
            let holder = CacheHolder<T>(item: item, date: Date(), timeToLive: timeToLive)
            guard let data = try? JSONEncoder().encode(holder), let json = String(data: data, encoding: .utf8) else {
                completionHandler(nil,item)
                return
            }
            
            self.defaults.set(json, forKey: key.rawValue)
            completionHandler(nil,item)
        }
    }
}

extension CacheContract {
    func get<T: Codable>(key: CacheKey, type: T.Type, timeToLive: TimeInterval = 300, fetch: (@escaping (Error?,T?) -> ()) -> (), completionHandler: @escaping (Error?,T?) -> ()) {
        self.get(key: key, type: type, timeToLive: timeToLive, fetch: fetch, completionHandler: completionHandler)
    }
    
    func put<T: Codable>(item: T, in key: CacheKey, timeToLive: TimeInterval = 300) {
        self.put(item: item, in: key, timeToLive: timeToLive)
    }
}
