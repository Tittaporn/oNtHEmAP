//
//  OTMClient.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/18/20.
//

import Foundation

class OMTClient {
    
    struct Auth {
        static var sessionId = ""
        static var key = ""
        static var firstName = ""
        static var lastName = ""
        static var objectId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        case login
        case signUp
        case getStudentLocation
        case addLocation
        case updateLocation(String)
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
            case .addLocation:
                return Endpoints.base + "/StudentLocation"
            case .updateLocation(let objectId):
                return Endpoints.base + "/StudentLocation/\(objectId)"
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
    
    //MARK : -LoginVC
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let udacity = ["username":username,"password":password]
        let body = LoginRequest(udacity: udacity)
        
        taskForPOSTRequest(url: Endpoints.login.url, responseType: LoginResponse.self, body: body, addAccept: true, newData: true) { (response, error) in
            if let response = response
            {
                Auth.sessionId = response.session.id
                Auth.key = response.account.key
                print(" Auth.key in class func login>>>>>>\(Auth.key)")
                print("response.account.key in class func login>>>>>>\(response.account.key)")
                
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
                print("UserInfo.user?.userKey in class func login>>>>>>\(String(describing: UserInfo.user?.userKey))")
                print("response.account.key in class func login>>>>>>\(response?.account.key ?? "")")
            }
        }
    }
    
    class func getLoggedInUserInfo(completion: @escaping (Bool, Error?) -> Void) {
        _ = taskForGETRequest(url: Endpoints.getLoggedInUserInfo.url, response: GetUserData.self, newData: true)
        { (response, error) in
            if let response = response {
                print("First Name : \(response.firstName) && Last Name : \(response.lastName)")
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completion(true, nil)
            } else {
                print("If failed in getLoggedInUserInfo >>>>>First Name : \(String(describing: response?.firstName)) && Last Name : \(String(describing: response?.lastName))")
                print("Failed to get logged in user's info.")
                completion(false, error)
            }
        }
    }
    
    
    //MARK : -StudentInfoForMapAndTableVC(getStudentLocation, logout and updateLocation)
    class func getStudentLocation(completion: @escaping ([StudentLocation], Error?) -> Void) {
        _ = taskForGETRequest(url: Endpoints.getStudentLocation.url, response: GetStudentLocation.self, newData: false)
        {(response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func updateLocation() {
        var request = URLRequest(url:Endpoints.updateLocation(Auth.objectId).url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(StudentInfoList.studentInfoList)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    print("Unsuccessful Update Location !!")
                }
                return
            }
            DispatchQueue.main.async {
                print("Successful Update Location !!")
            }
        }
        task.resume()
    }
    
    class func deleteSessionForLogOut (){
        var request = URLRequest(url: Endpoints.logOut.url)
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
    
    //MARK : FinishAddLocationVC
    class func addLocation(newInfo: StudentLocation, completion: @escaping (Bool, Error?) -> Void) {
        taskForPOSTRequest(url: Endpoints.addLocation.url, responseType: PostStudentLocation.self, body: newInfo, addAccept: false, newData: false) {(response, error) in
            if let response = response {
                OTMManager.otmManager.objectId = response.objectId
                Auth.objectId = response.objectId
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func updateStudentLocation(objectId: String, newStudentLocation: StudentLocation, completionHandler: @escaping (Error?) -> Void) {
        var request = URLRequest(url:Endpoints.updateLocation(objectId).url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(newStudentLocation)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    print("Unsuccessful Update Student Location !!")
                    completionHandler(error!)
                }
                return
            }
            DispatchQueue.main.async {
                print("Successful Update Student Location !!")
                completionHandler(nil)
            }
        }
        task.resume()
    }
}


