//
//  Exercise.swift
//  Refactoring
//
//  Created by Kai Lee on 1/10/25.
//

import Foundation

// MARK: - 1
class Moving_Exercise {
    class First_Before {
        class Library {
            var books: [Book] = []
            var bookCount = 0
            
            func addBook(_ book: Book) {
                books.append(book)
                bookCount = books.count
            }
            
            func borrowBook(bookID: String, user: User) {
                if let index = books.firstIndex(where: { $0.bookID == bookID && $0.isAvailable }) {
                    books[index].isAvailable = false
                    user.borrowedBooks.append(books[index])
                } else {
                    print("Book not available.")
                }
            }
            
            func printBookCount() {
                print("Total books in library: \(bookCount)")
            }
        }
        
        class Book {
            let bookID: String
            var title: String
            var author: String
            var isAvailable: Bool
            
            init(bookID: String, title: String, author: String, isAvailable: Bool = true) {
                self.bookID = bookID
                self.title = title
                self.author = author
                self.isAvailable = isAvailable
            }
        }
        
        class User {
            var userID: String
            var borrowedBooks: [Book] = []
            
            init(userID: String) {
                self.userID = userID
            }
        }
    }
    
    // MARK: - Refactored
    class First_After {
        class Library {
            var books: [Book] = []
            
            func addBook(_ book: Book) {
                books.append(book)
            }
            
            func borrowBook(bookID: String, by user: User) {
                guard let index = books.firstIndex(where: { $0.bookID == bookID && $0.isAvailable }) else {
                    print("Book not available.")
                    return
                }
                let bookToBorrow = books[index]
                bookToBorrow.isAvailable = false
                
                // Move Method를 통해 User가 borrowedBooks를 관리하도록 변경
                user.borrow(bookToBorrow)
            }
            
            func printBookCount() {
                // 불필요한 bookCount 필드를 제거하고, books.count 직접 사용
                print("Total books in library: \(books.count)")
            }
        }
        
        class Book {
            let bookID: String
            var title: String
            var author: String
            var isAvailable: Bool
            
            init(bookID: String, title: String, author: String, isAvailable: Bool = true) {
                self.bookID = bookID
                self.title = title
                self.author = author
                self.isAvailable = isAvailable
            }
        }
        
        class User {
            var userID: String
            var borrowedBooks: [Book] = []
            
            init(userID: String) {
                self.userID = userID
            }
            
            // Move Method 적용: User 스스로 borrowedBooks를 업데이트
            func borrow(_ book: Book) {
                borrowedBooks.append(book)
            }
        }
    }
}

extension Moving_Exercise {
    class Second_Before {
        class BankAccount {
            var balance: Double
            var currencyFormatter: CurrencyFormatter

            init(balance: Double, currencyFormatter: CurrencyFormatter) {
                self.balance = balance
                self.currencyFormatter = currencyFormatter
            }

            func deposit(_ amount: Double) {
                balance += amount
            }

            func withdraw(_ amount: Double) {
                if balance >= amount {
                    balance -= amount
                } else {
                    print("Insufficient funds.")
                }
            }

            func printBalance() {
                let formatted = currencyFormatter.format(balance)
                print("Current balance: \(formatted)")
            }
        }

        class CurrencyFormatter {
            func format(_ amount: Double) -> String {
                return String(format: "%.2f USD", amount)
            }
        }
    }
    
    class Second_After {
        class BankAccount {
            private var balance: Double
            private let currencyFormatter: CurrencyFormatter

            init(balance: Double, currencyFormatter: CurrencyFormatter) {
                self.balance = balance
                self.currencyFormatter = currencyFormatter
            }

            func deposit(_ amount: Double) {
                balance += amount
            }

            func withdraw(_ amount: Double) {
                guard balance >= amount else {
                    print("Insufficient funds.")
                    return
                }
                balance -= amount
            }

            // 클라이언트는 포맷터에 대해 알 필요가 없음(Hide Delegate)
            func printBalance() {
                print("Current balance: \(formattedBalance())")
            }

            private func formattedBalance() -> String {
                return currencyFormatter.format(balance)
            }
        }

        class CurrencyFormatter {
            func format(_ amount: Double) -> String {
                return String(format: "%.2f USD", amount)
            }
        }
    }
    
    class Second_After_2 {
        class BankAccount {
            var balance: Double
            var currencyFormatter: CurrencyFormatter
            
            init(balance: Double, currencyFormatter: CurrencyFormatter) {
                self.balance = balance
                self.currencyFormatter = currencyFormatter
            }
            
            func deposit(_ amount: Double) {
                balance += amount
            }
            
            func withdraw(_ amount: Double) {
                guard balance >= amount else {
                    print("Insufficient funds.")
                    return
                }
                balance -= amount
            }
            
            // 포맷 과정은 클라이언트가 직접 currencyFormatter로 접근하도록 공개
            // '중간자'가 되지 않도록 제거
            
            
            class CurrencyFormatter {
                func format(_ amount: Double) -> String {
                    return String(format: "%.2f USD", amount)
                }
            }
        }
    }
}

extension Moving_Exercise {
    class Third_Before {
        class UserProfile {
            var userID: String
            var name: String
            var address: String
            var phoneNumber: String
            var email: String
            // 아래 항목들은 "ExtraContactInfo"에서만 쓰이는 정보라고 가정
            var secondaryEmail: String?
            var faxNumber: String?

            init(userID: String, name: String, address: String, phoneNumber: String, email: String) {
                self.userID = userID
                self.name = name
                self.address = address
                self.phoneNumber = phoneNumber
                self.email = email
            }
            
            func printPrimaryContact() {
                print("\(name), \(phoneNumber), \(email)")
            }

            func printAllContactInfo() {
                print("\(name), \(phoneNumber), \(email)")
                if let secondary = secondaryEmail {
                    print("Secondary Email: \(secondary)")
                }
                if let fax = faxNumber {
                    print("Fax: \(fax)")
                }
            }
        }
    }
    
    class Third_After {
        class UserProfile {
            let userID: String
            var name: String
            var address: String
            var phoneNumber: String
            var email: String
            var extraContactInfo: ExtraContactInfo?  // Extract Class 적용

            init(userID: String, name: String, address: String, phoneNumber: String, email: String) {
                self.userID = userID
                self.name = name
                self.address = address
                self.phoneNumber = phoneNumber
                self.email = email
            }
            
            func printPrimaryContact() {
                print("\(name), \(phoneNumber), \(email)")
            }

            func printAllContactInfo() {
                print("\(name), \(phoneNumber), \(email)")
                extraContactInfo?.printExtraInfo()
            }
        }

        class ExtraContactInfo {
            var secondaryEmail: String?
            var faxNumber: String?

            init(secondaryEmail: String? = nil, faxNumber: String? = nil) {
                self.secondaryEmail = secondaryEmail
                self.faxNumber = faxNumber
            }

            func printExtraInfo() {
                if let secondary = secondaryEmail {
                    print("Secondary Email: \(secondary)")
                }
                if let fax = faxNumber {
                    print("Fax: \(fax)")
                }
            }
        }
    }
}
