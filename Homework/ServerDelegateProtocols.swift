import Alamofire

protocol ServerResponseDelegate {
    func serverActionCallback<T>(response: ServerResponse<T>)
}

protocol MultipartEncodedDelegate {
    func multipartEncodedCallback(encodingResult: MultipartEncodingResult)
}