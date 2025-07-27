import Foundation
import Supabase

class AuthService {
    static let shared = AuthService()
    let client: SupabaseClient

     init() {
        // Replace with your Supabase URL and anon key
        client = SupabaseClient(
            supabaseURL: URL(string: "https://aaxrtgfxvgudspmwnzkc.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFheHJ0Z2Z4dmd1ZHNwbXduemtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMyNzY1NDEsImV4cCI6MjA2ODg1MjU0MX0.sNEYSWGkdKjAIXXyIfxyLYdnzK7Z93cKn-E5Z3BYg2s"
        )
    }

    func register(email: String, password: String, completion: @escaping (Result<Session, Error>) -> Void) {
        Task {
            do {
                let response = try await client.auth.signUp(email: email, password: password)
                                if let session = response.session {
                    completion(.success(session))
                } else {
                    completion(.failure(NSError(domain: "No session returned", code: 0)))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }


func login(email: String, password: String, completion: @escaping (Result<Session, Error>) -> Void) {
    Task {
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            completion(.success(session))
        } catch {
            completion(.failure(error))
        }
    }
}

    func logout() async throws {
        try await client.auth.signOut()
    }


}
