//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 24/03/25.
//

import Foundation

public enum HTTPClientResult {
    
    case success (Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    
    func get (fromUrl url: URL, completion: @escaping (HTTPClientResult?) -> Void)
    
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
        
        client!.get(fromUrl :url) { response in
            
            switch response {
            case .success:
                
                completion(.invalidData)
            case .failure:
                completion(.Connectivity)
            case .none:
                completion (.invalidData)
            }
}
    }
}
