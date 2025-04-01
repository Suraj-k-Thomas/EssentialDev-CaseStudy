//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 24/03/25.
//

import Foundation

public protocol HTTPClient {
    
    func get (fromUrl url: URL, completion: @escaping (Error?) -> Void)
    
}


public final class RemoteFeedLoader {
    
    public enum Error : Swift.Error {
        
        case Connectivity
    }
    
    private let client : HTTPClient?
    private let url : URL
    
    public  init (client : HTTPClient, url : URL){
        
        self.client = client
        self.url = url
    }
    
    public  func load (completion : @escaping (Error?) -> Void = {_ in}){
        
        client!.get(fromUrl :url) { error in
            
            completion(.Connectivity)
        }
    }
}
