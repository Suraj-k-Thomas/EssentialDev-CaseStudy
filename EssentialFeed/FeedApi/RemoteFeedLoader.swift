//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 24/03/25.
//

import Foundation

public protocol HTTPClient {
    
    func get (fromUrl url: URL, completion: @escaping (Error?,HTTPURLResponse?) -> Void)
    
}


public final class RemoteFeedLoader {
    
    public enum Error : Swift.Error {
        
        case Connectivity
        case invalidData
    }
    
    private let client : HTTPClient?
    private let url : URL
    
    public  init (client : HTTPClient, url : URL){
        
        self.client = client
        self.url = url
    }
    
    public  func load (completion : @escaping (Error?) -> Void ){
        
        client!.get(fromUrl :url) { error,response in
            if response != nil {
                
                completion(.invalidData)
            }else {
                
                completion(.Connectivity)
            }}
    }
}
