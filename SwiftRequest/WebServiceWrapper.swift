//
//  WebServiceWrapper.swift
//  ZUPER PRO
//
//  Created by Sabari on 1/9/19.
//  Copyright © 2019 APPLE. All rights reserved.
//

import Foundation
public struct RequestService {
    
    
    /// Create shared instance for ZuperApi struct
    public static let shared = RequestService()
    
    //1 creating the session
    public static let session: URLSession = URLSession(configuration: .default)
    
    
    /// Create typealies for api response as [String:Any]
    public typealias JSON = (Result<[String:Any]?>) -> ()
    
    public typealias JSONTaskCompletionHandler = (Result<JSON>) -> ()
    
    public static func getRequest(url:String ,token: String? = nil,authType: AuthType? = nil, completionHandler completion: @escaping JSONTaskCompletionHandler) {
        
        guard let url = URL(string: url) else{
            completion(.Error(.invalidURL))
            return
        }
        
        let request = getUrlRequest(url: url, authType: authType, token: token)
        self.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session.configuration.urlCache = nil
        var task = URLSessionDataTask()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            task = self.session.dataTask(with: request) { (data, response, error) in
                
                DispatchQueue.main.async(execute: {
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.Error(.requestFailed))
                        return
                    }
                    
                    if httpResponse.statusCode == 200 {
                        
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.Success(json))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                    else if httpResponse.statusCode == 400 || httpResponse.statusCode == 401
                    {
                        
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.ApiError(json as! [String : String]))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                    else {
                        completion(.Error(.responseUnsuccessful))
                        print("\(String(describing: error))")
                    }
                })
            }
            task.resume()
        }
    }
    
    public static func postRequest(url:String ,token: String? = nil,authType: AuthType? = nil,postData:[String:Any],method:MethodType, completionHandler completion: @escaping JSONTaskCompletionHandler)  {
        
        guard let url = URL(string: url) else{
            completion(.Error(.invalidURL))
            return
        }
        
        /// Set request based on user input
        var request = getUrlRequest(url: url, authType: authType, token: token)
        request.httpMethod = method.rawValue
        
        self.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session.configuration.urlCache = nil
        
        if postData.count > 0
        {
            let jsonData = try? JSONSerialization.data(withJSONObject: postData)
            request.httpBody = jsonData
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var task = URLSessionDataTask()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            task = self.session.dataTask(with: request) { (data, response, error) in
                
                DispatchQueue.main.async(execute: {
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.Error(.requestFailed))
                        return
                    }
                    
                    if httpResponse.statusCode == 200 {
                        
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.Success(json))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                    else if httpResponse.statusCode == 400 ||  httpResponse.statusCode == 401
                    {
                        
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.ApiError(json as! [String : String]))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                    else if (httpResponse.statusCode == NSURLErrorCancelled || httpResponse.statusCode == NSURLErrorTimedOut || httpResponse.statusCode == NSURLErrorCannotConnectToHost || httpResponse.statusCode == NSURLErrorNetworkConnectionLost || httpResponse.statusCode == NSURLErrorNotConnectedToInternet || httpResponse.statusCode == NSURLErrorInternationalRoamingOff || httpResponse.statusCode == NSURLErrorCallIsActive || httpResponse.statusCode == NSURLErrorDataNotAllowed)
                    {
                        completion(.Error(.offline))
                    }
                    else {
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.ApiError(json as [String : Any]))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                })
            }
            task.resume()
        }
        
        
    }
    
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?) -> Void)
    {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            URLSession.shared.dataTask(with: url) {(data, response, error) in
                DispatchQueue.main.async(execute: {
                    if data != nil
                    {
                        if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode
                        {
                            completion(data)
                        }
                        else
                        {
                            completion(nil)
                        }
                    }
                    else
                    {
                        completion(nil)
                    }
                })
                }.resume()
        }
    }
}


public enum Result <T>{
    case Success([String:Any])
    case Error(ApiResponseError)
    case ApiError([String:Any])
}

public enum ApiResponseError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case invalidURL
    case jsonParsingFailure
    case offline
    
}

public enum MethodType:String{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum AuthType:String{
    case bearerToken = "Bearer"
    case xAuthToken = "X-Auth-Token"
    case none = "None"
}

func getUrlRequest(url:URL,authType:AuthType?,token:String?) -> URLRequest{
    
    var request = URLRequest(url: url)
    if let auth = authType{
        if let accessToken =  token{
            switch auth {
            case .bearerToken:
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            case .xAuthToken:
                request.setValue("\(accessToken)", forHTTPHeaderField: "X-Auth-Token")
            case .none:
                return request
            }
        }
    }
    
    return request
}


