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
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURls, [url, url])
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-different-url.com")!) -> (sut:RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURls = [URL]()
        
        func get(from url: URL) {
            requestedURls.append(url)
        }
    }

}
