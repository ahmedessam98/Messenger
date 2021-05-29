import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    private let scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let firstNameField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 30
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name....."
        field.leftView = UIView(frame: CGRect(x:  0, y: 0, width: 15, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 30
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name....."
        field.leftView = UIView(frame: CGRect(x:  0, y: 0, width: 15, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
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
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Log In"
        view.backgroundColor = .white
        
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        
        //Add SubView
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: (scrollView.width - size)/2,
                                 y: scrollView.top + 20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width / 2
        
        firstNameField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 30 ,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        lastNameField.frame = CGRect(x: 30,
                                  y: firstNameField .bottom + 10 ,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom + 10 ,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom + 10 ,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        registerButton.frame = CGRect(x: 50,
                                  y: passwordField.bottom + 30 ,
                                  width: scrollView.width - 100,
                                  height: 52)
        
    }
    
    @objc private func didTapChangeProfilePic() {
        
        presentPhotoActionSheet()
    }
    
    @objc private func didTapRegisterButton() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6  else {
         
            alertUserLoginError()
            return
        }
        
        //Firebase LogIn
        
        DatabaseManager.shared.userExists(with: email) { [weak self] exists in
            guard !exists else {
                //User already exist
                guard let strongSelf = self else {
                    return
                }
                strongSelf.alertUserLoginError(message: "Looks like that username you entered is already exist....")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult , error in
                
                guard authResult != nil , error == nil else {
                    print("Error creating account")
                    return
                }

                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                    lastName: lastName,
                                                                    emailAdress: email))
                self?.navigationController?.dismiss(animated: true, completion: nil )
            })
        }

    }
    
    func alertUserLoginError(message:String = "Please Enter the full Information to create a new Account "){
        let alert = UIAlertController(title: "Error in creating account",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension RegisterViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField {
            passwordField.becomeFirstResponder()
        }else if textField == lastNameField {
            emailField.becomeFirstResponder()
        }else if textField == emailField {
            passwordField.becomeFirstResponder()
        }else if textField == passwordField {
            didTapRegisterButton()
        }
        return true
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select your profile picture?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancell",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take a photo",
                                            style: .default,
                                            handler: { [weak self]_ in
                                                self?.presentCamera()
                                                
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Select a photo",
                                            style: .default,
                                            handler: {[weak self]_ in
                                                self?.presentPhotoPicker()
                                            }))
        
        present(actionSheet, animated: true)
        
    }
    
    func presentCamera() {
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
