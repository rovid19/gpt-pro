import Foundation

// singleton klase radim samo kad znam da je jedna instanca dovoljna
// i onda koristim shared property i bez init-a da klasa napravi sama svoju instancu
class UserStore {
    static let shared = UserStore()
    init() {}
    
  
    var email: String?
    
    func setUser( email: String?) {
        self.email = email
    }
    
    func clearUser() {
      
        self.email = nil
    }

func isUserLoggedIn() async -> Bool {
    NSLog("[UserStore] Checking if user is logged in")
    do {
        // Try to get current user directly from Supabase's saved session
        let user = try await AuthService.shared.client.auth.user()
        if let email = user.email {
            setUser(email: email)
            NSLog("[UserStore] User logged in: \(email)")
            return true
        } else {
            return false
        }
    } catch {
        print("[UserStore] Failed to fetch user from stored session: \(error)")
        return false
    }
}



}

protocol UserStoreDelegate: AnyObject {

    func userDidAuth(email: String)
    func userDidLogout() 
}
