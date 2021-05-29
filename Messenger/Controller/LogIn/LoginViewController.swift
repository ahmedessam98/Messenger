import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    private let scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 30
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Adress....."
        field.leftView = UIView(frame: CGRect(x:  0, y: 0, width: 15, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 30
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password....."
        field.leftView = UIView(frame: CGRect(x:  0, y: 0, width: 15, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let FbLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        FbLoginButton.delegate = self
        
        if let token = AccessToken.current,
            !token.isExpired {
            // User is logged in, do work such as go to next view controller.
        }
        
        
        //Add SubView
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(FbLoginButton)
//        FbLoginButton.center = scrollView.center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: (scrollView.width - size)/2,
                                 y: scrollView.top + 20,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 30 ,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10 ,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 50,
                                   y: passwordField.bottom + 30 ,
                                   width: scrollView.width - 100,
                                   height: 52)
        
        FbLoginButton.frame = CGRect(x: 50,
                                   y: loginButton.bottom + 30 ,
                                   width: scrollView.width - 100,
                                   height: 52)
    }
    
    @objc private func didTapLoginButton() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text , let password = passwordField.text , !email.isEmpty , !password.isEmpty , password.count >= 6 else {
         
            alertUserLoginError()
            return
        }
        
        //Firebase LogIn
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult , error in
            
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult , error == nil else {
                print("Error Log In with email : \(email)")
                return
            }
            let user = result.user
            print("Logged in with user : \(user).")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Error in Log In", message: "Please Enter the correct Information", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func didTapRegister() {
        
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

extension LoginViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }else if textField == passwordField {
            didTapLoginButton()
        }
        return true
    }
    
}


extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook account")
            return
        }
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email , name"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start { connection, result, error in
            guard let result = result as? [String: Any] , error == nil else {
                print("Failed to get Facebook request graph")
                return
            }
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                print("Failed to get name & email from Facebook request results")
                return
            }
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
                return
            }
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAdress: email))
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
             
                guard let strongSelf = self else {
                    return
                }
                guard authResult != nil , error == nil else {
                    if let error = error  {
                    print("Error logging with facebook account , error is : \(error).")
                    }
                    return
                }
                print("Succefully logging in with facebookaccount.")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        

    }
    
}
