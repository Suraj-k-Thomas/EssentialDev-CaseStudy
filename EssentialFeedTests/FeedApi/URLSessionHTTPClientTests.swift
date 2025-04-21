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
        session.dataTask(with: url) { _, _, _ in}.resume()
    }
}
class URLSessionHTTPClientTests :XCTestCase{
    
    func test_getFromURL_resumesDataTaskWithURL () {
        
        let session = URLSessionSpy()
        let url = URL(string: "https://a-url.com")!
        let sut = URLSessionHTTPClient(session: session)
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, dataTask: task)
        sut.get(from: url)
        XCTAssertEqual(task.resumeCallCount,1)
    }
    
    //Helpers
    
    private class URLSessionSpy : URLSession {
        private var  stubs = [URL:URLSessionDataTask]()
        
       func stub(url: URL, dataTask: URLSessionDataTaskSpy) {
           stubs[url] = dataTask
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? fakeURLSessionDataTask ()
        }
        
        
    }
    
    private class fakeURLSessionDataTask : URLSessionDataTask {
        override func resume() {}
    }
    private class URLSessionDataTaskSpy : URLSessionDataTask {
        
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }

}
