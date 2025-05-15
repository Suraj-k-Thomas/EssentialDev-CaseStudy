//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Suraj  Thomas on 20/04/25.
//

import Testing
import XCTest
import EssentialFeed

class URLSessionHTTPClient  {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url : URL, completion :@escaping( HTTPClientResult)-> Void){
        session.dataTask(with: url) { _, _, error in
            
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}
class URLSessionHTTPClientTests :XCTestCase{
    
    
    func test_getFromURL_failsonRequestError(){
        
        URLProtocolstub.startInterceptingRequests()
        let url = URL(string: "https://a-url.com")!
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "completion handler invoked")
        let error = NSError(domain: "some error", code: 1)
        URLProtocolstub.stub(url: url, data : nil , response : nil ,  error: error)
        sut.get(from: url){result in
            switch result
            {
            case .failure(let recievedError as NSError):
                XCTAssertEqual(error,error)
            default:
                XCTFail()
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolstub.startInterceptingRequests()    }
    
    //Helpers
    
    private class URLProtocolstub : URLProtocol {
        static private var stubs = [URL:Stub]()
        
        private struct Stub {
            let data : Data?
            let response : URLResponse?
            let error : Error?
          
        }
        
        
        static  func stub(url: URL,data: Data?,response : URLResponse? ,error:Error?) {
            stubs[url] = Stub(data: data, response: response ,error:error)
        }
        
        static func startInterceptingRequests () {
            URLProtocol.registerClass(URLProtocolstub.self)
        }
        
        static func stopInterceptingRequests () {
            
            URLProtocol.unregisterClass(URLProtocolstub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            
            guard let url = request.url else {return false}
            return URLProtocolstub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            guard let url = request.url , let stub = URLProtocolstub.stubs[url] else {return}
            
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self,didFailWithError : error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
}
