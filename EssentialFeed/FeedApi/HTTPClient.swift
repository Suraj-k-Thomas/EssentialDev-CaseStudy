//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 08/04/25.
//

import Foundation

public enum HTTPClientResult {
    
    case success (Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    
    func get (fromUrl url: URL, completion: @escaping (HTTPClientResult?) -> Void)
    
}
