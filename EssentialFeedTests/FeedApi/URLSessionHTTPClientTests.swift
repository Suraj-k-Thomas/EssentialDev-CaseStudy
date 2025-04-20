//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Suraj  Thomas on 20/04/25.
//

import Testing
import XCTest


class URLSessionHTTPClient  {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url : URL){
        session.dataTask(with: url) { _, _, _ in}
    }
}
class URLSessionHTTPClientTests :XCTestCase{

    func test_getFromURL_createDataTaskWithURL () {
        
        let session = URLSessionSpy()
        let url = URL(string: "https://a-url.com")!
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        XCTAssertEqual(session.recievedUrls, [url])
    }
    
    class URLSessionSpy : URLSession {
        var recievedUrls = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            recievedUrls.append(url)
            return fakeURLSessionDataTask ()
        }
        
    }
    
    private class fakeURLSessionDataTask : URLSessionDataTask {}

}
