import Cocoa

class RegisterView: NSView {
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
    let registerButton: NSButton = {
        let button = NSButton(title: "Register", target: nil, action: nil)
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let googleButton: NSButton = {
        let button = NSButton(title: "Sign up with Google", target: nil, action: nil)
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let appleButton: NSButton = {
        let button = NSButton(title: "Sign up with Apple", target: nil, action: nil)
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let loginLinkButton: NSButton = {
        let button = NSButton(title: "Already a user? Login", target: nil, action: nil)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(registerButton)
        stackView.addArrangedSubview(googleButton)
        stackView.addArrangedSubview(appleButton)
        stackView.addArrangedSubview(loginLinkButton)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            emailField.widthAnchor.constraint(equalToConstant: 220),
            passwordField.widthAnchor.constraint(equalToConstant: 220),
            registerButton.widthAnchor.constraint(equalToConstant: 220),
            googleButton.widthAnchor.constraint(equalToConstant: 220),
            appleButton.widthAnchor.constraint(equalToConstant: 220)
            // loginLinkButton will size to fit
        ])
        loginLinkButton.target = self
        loginLinkButton.action = #selector(loginLinkTapped)
        registerButton.target = self
        registerButton.action = #selector(handleRegister)
    }

    @objc private func loginLinkTapped() {
        authDelegate?.authViewClosed()
        authDelegate?.renderNewView("login")
    }

    @objc private func handleRegister() {
        let email = emailField.stringValue
        let password = passwordField.stringValue
        guard !email.isEmpty, !password.isEmpty else {
            NSLog("[RegisterView] Email or password is empty")
            return
        }
        AuthService.shared.register(email: email, password: password) { result in
            switch result {
            case .success(let session):
            self.appDelegate?.userDidAuth(email:email)
                NSLog("[RegisterView] Supabase user: \(session.user)")
            case .failure(let error):
                NSLog("[RegisterView] Registration error: \(error)")
            }
        }
    }
}
