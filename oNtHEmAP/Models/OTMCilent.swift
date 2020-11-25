//
//  OTMCilent.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/18/20.
//

import Foundation

class OMTCilent {
    
    struct Auth {
        static var sessionId = ""
        static var key = ""
        static var updateAt = ""
        static var firstName = ""
        static var lastName = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case signUp
        case getStudentLocation
        case addLocation
        case updateLocation
        case getLoggedInUserInfo
        case logOut
        
        var stringValue: String {
            switch self {
            case .login:
                return Endpoints.base + "/session"
            case .signUp:
                return "https://auth.udacity.com/sign-up"
            case .getStudentLocation:
                return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
                //"/StudentLocation?limit=100?order=-updatedAt"
                //"/StudentLocation?limit=100&order=-updatedAt" >>>> Maybe this one the rigth one
            case .addLocation:
                return Endpoints.base + "/StudentLocation"
            case .updateLocation:
                return Endpoints.base + "/StudentLocation" + Auth.updateAt
            case .getLoggedInUserInfo:
                return Endpoints.base + "/users/" + Auth.key
            case .logOut:
                return Endpoints.base + "/session"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    //MARK : -TasksForRequest
      
    class func taskForGETRequest<ResponseType:Decodable>(url: URL, response: ResponseType.Type, newData: Bool, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask
    {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
                return
            }
            
            var getNewData:Data
            
            if(newData)
            {
                let range = 5..<data.count
                let tryData = data.subdata(in: range)
                getNewData = tryData
            }
            else
            {
                getNewData = data
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: getNewData)
                DispatchQueue.main.async
                {
                    completion(responseObject, nil)
                }
            } catch {
                do
                    {
                        let errorResponse = try decoder.decode(LoginError.self, from: getNewData)
                        DispatchQueue.main.async
                        {
                            completion(nil, errorResponse)
                        }
                    }
                catch
                {
                    DispatchQueue.main.async
                    {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType,addAccept: Bool,newData:Bool, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if(addAccept)
        {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try! JSONEncoder().encode(body)

        let task = URLSession.shared.dataTask(with: request)
        { (data, response, error) in
            guard let data = data else
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
                return
            }
            
            //get rid of first 5 characters in data
            var getNewData:Data
            if(newData)
            {
                let range = 5..<data.count
                let tryNewData = data.subdata(in: range)
                getNewData = tryNewData
            }
            else
            {
                getNewData = data
            }
            
            let decoder = JSONDecoder()
            do
            {
                let responseObject = try decoder.decode(ResponseType.self, from: getNewData)

                DispatchQueue.main.async
                {
                    completion(responseObject,nil)
                }
            }
            catch
            {
                do
                {
                    let errorResponse = try decoder.decode(LoginError.self, from: getNewData)
                    DispatchQueue.main.async
                    {
                        completion(nil, errorResponse)
                    }
                }
                catch
                {
                    DispatchQueue.main.async
                    {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    //MARK : -LoginViewController
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let udacity = ["username":username,"password":password]
        let body = LoginRequest(udacity: udacity)
        
        taskForPOSTRequest(url: Endpoints.login.url, responseType: LoginResponse.self, body: body, addAccept: true, newData: true) { (response, error) in
            if let response = response
            {
                //save session id and user key
                Auth.sessionId = response.session.id
                UserInfo.user?.userKey = response.account.key
                getLoggedInUserInfo(completion: { (success, error) in
                                    if success {
                                        print("Logged in user's profile fetched.")
                                    }
                                })
                
                completion(true, nil)
            }
            else
            {
                completion(false, error)
            }
        }
    }
    
    class func getLoggedInUserInfo(completion: @escaping (Bool, Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.getLoggedInUserInfo.url, response: GetUserData.self, newData: true)
        { (response, error) in
            if let response = response {
                print("First Name : \(response.firstName) && Last Name : \(response.lastName)")
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completion(true, nil)
            } else {
                print("Failed to get logged in user's info.")
               completion(false, error)
            }
        }
    }
    
    
    //MARK : -StudentInfoForMapAndTableViewController
    
    class func getStudentLocation(completion: @escaping ([StudentLocation], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getStudentLocation.url, response: GetStudentLocation.self, newData: false)
            {(response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
        }
    }
}
    
    //MARK : -AddLocationViewController
    class func addLocation(newInfo: StudentLocation, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"uniqueKey\": \"\(newInfo.uniqueKey ?? "")\", \"firstName\": \"\(newInfo.firstName ?? "")\", \"lastName\": \"\(newInfo.lastName ?? "")\",\"mapString\": \"\(newInfo.mapString ?? "")\", \"mediaURL\": \"\(newInfo.mediaURL ?? "")\",\"latitude\": \(newInfo.latitude ?? 0.0), \"longitude\": \(newInfo.longitude ?? 0.0)}"
        taskForPOSTRequest(url: Endpoints.addLocation.url, responseType: PostStudentLocation.self, body: body, addAccept: false, newData: false) {(response, error) in
            if let response = response {
                UserInfo.currentLocationId = response.objectId
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
}


//
//        taskForGetRequest(url: Endpoints.getLoggedInUserInfo.url, response: GetUserData.self, newData: true)
//        { (response, error) in
//            if let response = response {
//                print("First Name : \(response.firstName) && Last Name : \(response.lastName)")
//                Auth.firstName = response.firstName
//                Auth.lastName = response.lastName
//                completion(true, nil)
//            } else {
//                print("Failed to get logged in user's info.")
//                completion(false, error)
//            }
//        }

/*}


    class func taskForGetRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, newData: Bool, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        
         let task = URLSession.shared.dataTask(with: url) { data, response, error in
             guard let data = data else {
                 DispatchQueue.main.async {
                     completion(nil, error)
                 }
                 return
             }
            var getNewData: Data
            if(newData) {
                let range = 5..<data.count
                let tryNewData = data.subdata(in: range)
                 getNewData = tryNewData
            } else {
                getNewData = data
            }
          
             let decoder = JSONDecoder()
             do {
                 let responseObject = try decoder.decode(ResponseType.self, from: getNewData)
                 DispatchQueue.main.async {
                     completion(responseObject, nil)
                 }
             } catch {
                do {
                     let errorResponse = try decoder.decode(OTMResponse.self, from: getNewData) as Error
                     DispatchQueue.main.async {
                         completion(nil, errorResponse)
                     }
                 } catch {
                     DispatchQueue.main.async {
                         completion(nil, error)
                     }
                 }
             }
         }
    task.resume()
    return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType,newData: Bool, completion: @escaping (ResponseType?, Error?) -> Void) {
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         request.httpBody = try! JSONEncoder().encode(body)
         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         let task = URLSession.shared.dataTask(with: request) { data, response, error in
             guard let data = data else {
                 DispatchQueue.main.async {
                     completion(nil, error)
                 }
                 return
             }
            
            var getNewdata: Data
            if(newData) {
                let range = 5..<data.count
                let tryNewData = data.subdata(in: range)
                 getNewdata = tryNewData
            } else {
                getNewdata = data
            }
             let decoder = JSONDecoder()
             do {
                 let responseObject = try decoder.decode(ResponseType.self, from: getNewdata)
                 DispatchQueue.main.async {
                     completion(responseObject, nil)
                 }
             } catch {
                 do {
                     let errorResponse = try decoder.decode(OTMResponse.self, from: getNewdata) as Error
                     DispatchQueue.main.async {
                         completion(nil, errorResponse)
                     }
                 } catch {
                     DispatchQueue.main.async {
                         completion(nil, error)
                     }
                 }
             }
         }
         task.resume()
     }
    
    class func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        
        taskForPOSTRequest(url: Endpoints.logIn.url, responseType: PostSession.self, body: body, newData: true) { response, error in
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.key = response.account.key
//                //getLoggedInUserInfo(completion: { (success, error) in
//                    if success {
//                        print("Logged in user's profile fetched.")
//                    }
//                })
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
}

    class func getLoggedInUserInfo(completion: @escaping (Bool, Error?) -> Void) {
        
        taskForGetRequest(url: <#T##URL#>, response: <#T##Decodable.Protocol#>, newData: <#T##Bool#>, completion: <#T##(Decodable?, Error?) -> Void#>)
        taskForGetRequest(url: Endpoints.getLoggedInUserInfo.url, response: GetUserData.self, newData: true) { (response, error) in
            if let response = response {
                print("First Name : \(response.firstName) && Last Name : \(response.lastName)")
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completion(true, nil)
            } else {
                print("Failed to get logged in user's info.")
                completion(false, error)
            }
        }
    }
}

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    class func getStudentLocation5<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            print(String(data: data!, encoding: .utf8)!)
        }
        task.resume()
    }
    
    class func postingStudentLocation6 <ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            print(String(data: data!, encoding: .utf8)!)
        }
        task.resume()
        
    }
    
    class func puttingStudentLocation7 <ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        let urlString = "https://onthemap-api.udacity.com/v1/StudentLocation/8ZExGR5uX8"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Cupertino, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.322998, \"longitude\": -122.032182}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            print(String(data: data!, encoding: .utf8)!)
        }
        task.resume()    }
    
    class func postingSession9 <ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // encoding a JSON body from a string, can also use a Codable struct
        request.httpBody = "{\"udacity\": {\"username\": \"account@domain.com\", \"password\": \"********\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(newData ?? "")
        }
        task.resume()
    }
    
    class func deleteSession10 <ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(newData ?? "")
        }
        task.resume()
    }
    
    class func getPublicUserData11 <ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/3903878747")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(newData ?? "")
        }
        task.resume()
    }
    
    
    ///making request
//    import UIKit
//    import PlaygroundSupport
//
//    // this line tells the Playground to execute indefinitely
//    PlaygroundPage.current.needsIndefiniteExecution = true

    class func makingRequest <ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        let urlString = "http://quotes.rest/qod.json?category=inspire"
           let url = URL(string: urlString)
           let request = URLRequest(url: url!)
           let session = URLSession.shared
           let task = session.dataTask(with: request) { data, response, error in
               if error != nil { // Handle error
                   return
               }
               print(String(data: data!, encoding: .utf8)!)
           }
           task.resume()
    }
}
*/
