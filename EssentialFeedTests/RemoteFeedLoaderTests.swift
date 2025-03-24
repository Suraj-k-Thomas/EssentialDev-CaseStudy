//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Suraj  Thomas on 24/03/25.
//

import Testing
import XCTest

class RemoteFeedLoader {
    
    let client : HTTPClient?
    init (client : HTTPClient){
        
        self.client = client
    }
    func load (){
        
        client!.get(fromUrl :URL(string: "https://TestUrl.com")!)
        
    }
}

protocol HTTPClient {
    
    func get (fromUrl url: URL)
    
}

class HTTPClientSpy : HTTPClient {
    
    var requestedUrl: URL?
     func get (fromUrl url: URL) {
        requestedUrl = url
    }
}

class RemoteFeedLoaderTests : XCTestCase {
    
    func test_init_DoesNotREqruireDataFromURL () {
        
        let Client = HTTPClientSpy ()
        let _ = RemoteFeedLoader(client: Client)
        XCTAssertNil(Client.requestedUrl)
    }
    
    func test_LoadRequestDataFromURL () {
        
        let Client = HTTPClientSpy ()
        let SUT = RemoteFeedLoader(client:Client)
        SUT.load()
        XCTAssertNotNil(Client.requestedUrl)
        
    }
}
