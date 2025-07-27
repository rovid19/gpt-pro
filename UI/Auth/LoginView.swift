import Cocoa

protocol AuthViewDelegate: AnyObject {
    func authViewClosed()
    func renderNewView(_ type: String)
}

class LoginView: NSView {
    weak var appDelegate: UserStoreDelegate?
    weak var authDelegate: AuthViewDelegate?

    let emailField: NSTextField = {
        let field = NSTextField()
        field.placeholderString = "Email"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let passwordField: NSSecureTextField = {
        let field = NSSecureTextField()
        field.placeholderString = "Password"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let loginButton: NSButton = {
        let button = NSButton(title: "Login", target: nil, action: nil)
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let googleButton: NSButton = {
        let button = NSButton(title: "Sign in with Google", target: nil, action: nil)
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let appleButton: NSButton = {
        let button = NSButton(title: "Sign in with Apple", target: nil, action: nil)
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let registerTextButton: NSButton = {
        let button = NSButton(title: "Don't have an account? Register", target: nil, action: nil)
        button.bezelStyle = .inline
        button.isBordered = false
        button.font = NSFont.systemFont(ofSize: 13)
        button.contentTintColor = .linkColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let stackView: NSStackView = {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 12
        stack.alignment = .centerX
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
     init(frame frameRect: NSRect, appDelegate: UserStoreDelegate?, authDelegate: AuthViewDelegate?) {
        super.init(frame: frameRect)
        self.appDelegate = appDelegate
         self.authDelegate = authDelegate
        setupUI()
        loginButton.target = self
        loginButton.action = #selector(handleLogin)
        registerTextButton.target = self
        registerTextButton.action = #selector(handleRegisterTapped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(googleButton)
        stackView.addArrangedSubview(appleButton)
        stackView.addArrangedSubview(registerTextButton)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            emailField.widthAnchor.constraint(equalToConstant: 220),
            passwordField.widthAnchor.constraint(equalToConstant: 220),
            loginButton.widthAnchor.constraint(equalToConstant: 220),
            googleButton.widthAnchor.constraint(equalToConstant: 220),
            appleButton.widthAnchor.constraint(equalToConstant: 220),
            registerTextButton.widthAnchor.constraint(equalToConstant: 220)
        ])
    }

    @objc func handleLogin() {
        let email = emailField.stringValue
        let password = passwordField.stringValue
        AuthService.shared.login(email: email, password: password) { result in
            switch result {
            case .success(let session):
                self.appDelegate?.userDidAuth(email: email)
            case .failure(let error):
                print(error)
            }
        }
    }

    @objc func handleRegisterTapped() {
        authDelegate?.authViewClosed()
        authDelegate?.renderNewView("register")
    }
}




