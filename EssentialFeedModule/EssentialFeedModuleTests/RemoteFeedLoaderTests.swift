//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedModuleTests
//
//  Created by Hiram Castro Maldonado on 29/10/21.
//

import XCTest
import EssentialFeedModule

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURls.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURls, [url])
    }
    
    func test_loadTwice_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURls, [url, url])
    }
    
    func test_load_deliverysErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load {
            // 4 - after execute the completion handler in load method from RemoteFeedLoader
            // we return the result to be saved and then validated
            capturedError.append($0)
        }
        
        let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    func test_load_deliverysErrorOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach {
            index, code in
            
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load {
                // 4.1 - after execute the completion handler in load method from RemoteFeedLoader
                // we return the result to be saved and then validated
                capturedErrors.append($0)
            }
            
            client.complete(withStatusCode: code, at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
        
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let invalidJSON = Data.init("invalid json".utf8)
        client.complete(withStatusCode: 200, data: invalidJSON)
        
        XCTAssertEqual(capturedErrors, [.invalidData])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-different-url.com")!) -> (sut:RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void )]()
        
        var requestedURls:[URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            // 2 - capturing the completion habdler.
            // won't execute because it's captured in a array of closures to excute it later
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            // 3 - executing previous captured completion handler
            // and return it to the main caller (RemoteFeedLoader - load)
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            // 3 - executing previous captured completion handler
            // and return it to the main caller (RemoteFeedLoader - load)
            let response = HTTPURLResponse(url: requestedURls[index],
                                           statusCode: 400,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }

}
