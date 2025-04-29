import Foundation

class BlockingURLProtocol: URLProtocol {
    static var urlsToBlock: Set<String> = []
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let urlString = request.url?.absoluteString else {
            return false
        }
        
        if urlsToBlock.contains(where: { urlStringToBlock in urlString.contains(urlStringToBlock) }) {
            print("BlockingURLProtocol: Blocking specific request to \(urlString)")
            return true
        }
        
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: [NSLocalizedDescriptionKey: "Request blocked by UI test configuration."])
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    override func stopLoading() {}
    
    static func reset() {
        urlsToBlock.removeAll()
    }
}
