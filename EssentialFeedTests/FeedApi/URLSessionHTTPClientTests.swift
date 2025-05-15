//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Suraj  Thomas on 20/04/25.
//

import Testing
import XCTest
import EssentialFeed

protocol HTTPSession {
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HttpSessionDataTask
}

protocol HttpSessionDataTask {
    func resume()
}

class URLSessionHTTPClient  {
    
    private let session: HTTPSession
    
    init(session: HTTPSession) {
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
    
    func test_getFromURL_resumesDataTaskWithURL () {
        
        let session = HTTPSessionSpy()
        let url = URL(string: "https://a-url.com")!
        let sut = URLSessionHTTPClient(session: session)
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, dataTask: task)
        sut.get(from: url){_ in }
        XCTAssertEqual(task.resumeCallCount,1)
    }
    
    func test_getFromURL_failsonRequestError(){
        
        let session = HTTPSessionSpy()
        let url = URL(string: "https://a-url.com")!
        let sut = URLSessionHTTPClient(session: session)
        let exp = expectation(description: "completion handler invoked")
        let task = URLSessionDataTaskSpy()
        let error = NSError(domain: "some error", code: 1)
        session.stub(url: url, dataTask: task,error: error)
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
    }
    
    //Helpers
    
    private class HTTPSessionSpy : HTTPSession {
        private var  stubs = [URL:Stub]()
        
        private struct Stub {
            let task : HttpSessionDataTask
            let error : Error?
        }
        
        
        func stub(url: URL, dataTask: HttpSessionDataTask = fakeURLSessionDataTask(),
                  error:Error? = nil) {
            stubs[url] = Stub(task: dataTask, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HttpSessionDataTask {
           
            guard let stub = stubs[url] else{
                fatalError("couldnt find stub for \(url)")
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class fakeURLSessionDataTask : HttpSessionDataTask {
         func resume() {}
    }
    
    private class URLSessionDataTaskSpy : HttpSessionDataTask {
        
        var resumeCallCount = 0
        
         func resume() {
            resumeCallCount += 1
        }
    }

}
