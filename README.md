
# Swift Network Manager 

This swift package allows you to easily make network requests. 



## Run on your project

Using SPM: 

```spm
  https://github.com/batuhankucukyildiz/NetworkManager
```

## How to use it? 

After installing the package with SPM, create an endpoint file according to your project. A sample file might look like this:

## Use

1️⃣ Create a user enum
```swift
enum User {
    //MARK: User Operations
    case login(username: String, password: String)
}

extension User: EndpointProtocol {
    var baseUrl: String {
        return "http://example.com"
    }
    
    var path: String {
        switch self {
        case .login(_, _):
            return "api/v1/user/loginUser"
        }
    }
    
    var httpMethod: HttpMethods {
        switch self {
        case .login(_, _):
            return .post
        }
    }
    var headers: [String : Any]? {
        return nil
    }
    
    func request() -> URLRequest {
        guard var components = URLComponents(string: baseUrl) else {
            fatalError("Invalid URL")
        }
        components.path = path
        let encoder = JSONEncoder()
        var request = URLRequest(url: components.url!)
        request.httpMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // MARK: Login User
        if case let .login(username, password) = self {
            request.httpBody = try? encoder.encode(["username": username, "password": password])
        }
        return request
    }
}
```

2️⃣ Create a user model

```swift
struct UserModel: Decodable {
    var id: String?
    var username: String?
    var email: String?
}
```

3️⃣ Create Service Protocol


```swift
struct UserModel: Decodable {
    var id: String?
    var username: String?
    var email: String?
}
```
```swift
protocol UserServiceProtocol {
    func login(username: String, password: String, completion: @escaping(Result<UserModel, Error>) -> Void) -> Void
}

final class UserService: UserServiceProtocol {
    func login(username: String, password: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        let endpoint = User.login(username: username, password: password)
        NetworkManager.shared.request(endpoint, completion: completion)
    }
}
```

## Example usage for MVVM 

```swift
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    var loginService: UserServiceProtocol?
    init(loginService: UserServiceProtocol? = nil) {
        self.loginService = loginService
    }
    
    func login() {
        loginService?.login(username: username, password: password, completion: {
            [weak self] resultLoginInformation in
            guard let self = self else { return }
            switch resultLoginInformation {
            case .success(let loginModel):
                DispatchQueue.main.async {
                    print(loginModel)
                }
            case .failure(let error):
                print("errors: \(error.localizedDescription)")
            }
        })
    }
}
```
