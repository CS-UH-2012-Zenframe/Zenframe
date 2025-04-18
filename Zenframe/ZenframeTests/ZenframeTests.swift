import XCTest
import SwiftUI
import ViewInspector
@testable import Zenframe

// Make ProfilePage conform to Inspectable
extension ProfilePage: Inspectable {}

final class ProfilePageTests: XCTestCase {

//    func testProfilePageHasNavigationTitle() throws {
//        let sut = ProfilePage()
//        let navView = try sut.inspect().navigationView()
//        let title = try navView.navigationBar().title()
//        XCTAssertEqual(title, "Profile")
//    }

    func testProfilePageHasUserNameText() throws {
        let sut = ProfilePage()
        let vstack = try sut.inspect().navigationView().scrollView().vStack()
        let nameText = try vstack.text(1).string()
        XCTAssertEqual(nameText, "User: Asgar Fataymamode")
    }

    func testProfilePageHasEmailText() throws {
        let sut = ProfilePage()
        let vstack = try sut.inspect().navigationView().scrollView().vStack()
        let emailText = try vstack.text(2).string()
        XCTAssertEqual(emailText, "Email: asgar@gmail.com")
    }

    func testProfilePageHasLogoutButton() throws {
        let sut = ProfilePage()
        let vstack = try sut.inspect().navigationView().scrollView().vStack()
        let buttonCount = try vstack.count
        let lastButton = try vstack.button(buttonCount - 1).labelView().text().string()
        XCTAssertEqual(lastButton, "Log Out")
    }
}
