//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Suraj  Thomas on 24/03/25.
//

import Testing
import XCTest

class RemoteFeedLoader {
    
    func load (){
        
        HTTPClient.shared.get(fromUrl :URL(string: "https://TestUrl.com")!)
        
    }
}

class HTTPClient {
    
    static var shared = HTTPClient()
     init () {}
    func get (fromUrl url: URL) {}
    
}

class HTTPClientSpy : HTTPClient {
    
     var requestedUrl: URL?
    override func get (fromUrl url: URL) {
        requestedUrl = url
    }
}

class RemoteFeedLoaderTests : XCTestCase {
    
    func test_init_DoesNotREqruireDataFromURL () {
        
        let _ = RemoteFeedLoader()
        let Client = HTTPClientSpy ()
        HTTPClient.shared = Client
        XCTAssertNil(Client.requestedUrl)
    }
    
    func test_LoadRequestDataFromURL () {
        
        let SUT = RemoteFeedLoader()
        let Client = HTTPClientSpy ()
        HTTPClient.shared = Client
        SUT.load()
        XCTAssertNotNil(Client.requestedUrl)
        
    }
}
