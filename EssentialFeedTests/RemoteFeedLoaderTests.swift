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
        
        HTTPClient.shared.requestedUrl = URL(string: "https://TestUrl.com")!
    }
}

class HTTPClient {
    
    static let shared = HTTPClient()
    private init () {}
    var requestedUrl: URL?
    
    
}

class RemoteFeedLoaderTests : XCTestCase {
    
    func test_init_DoesNotREqruireDataFromURL () {
        
        let _ = RemoteFeedLoader()
        let Client = HTTPClient.shared
        XCTAssertNil(Client.requestedUrl)
    }
    
    func test_LoadRequestDataFromURL () {
        
        let SUT = RemoteFeedLoader()
        let Client = HTTPClient.shared
        SUT.load()
        XCTAssertNotNil(Client.requestedUrl)
        
    }
}
