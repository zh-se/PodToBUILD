//
//  UserConfigurableTests.swift
//  PodSpecToBUILD
//
//  Created by jerry on 5/2/17.
//  Copyright © 2017 jerry. All rights reserved.
//

import XCTest

enum TestTargetConfigurableKeys : String {
    case copts
}

struct TestTarget : BazelTarget, UserConfigurable {
    var name = "TestTarget"
    var copts = AttrSet(basic: [String]())

    func toSkylark() -> SkylarkNode {
        return .functionCall(
            name: "config_setting",
            arguments: [SkylarkFunctionArgument]()
        )
    }

    mutating func add(configurableKey: String, value: Any) {
        if let key = ObjcLibraryConfigurableKeys(rawValue: configurableKey) {
            switch key {
            case .copts:
                if let value = value as? String {
                    self.copts = self.copts <> AttrSet(basic: [value])
                }
            }
        }
    }
    
}

class UserConfigurableTests: XCTestCase {
    func testUserOptionTransform() {
        var target = TestTarget()
        target.copts = AttrSet(basic: ["-initial"])
        let attributes = UserConfigurableTargetAttributes(keyPathOperators:  ["TestTarget.copts += -foo, -bar"])
        let output = UserConfigurableTransform.executeUserOptionsTransform(onConvertibles: [target], copts: [String](), userAttributes: attributes)
        let outputLib = output[0] as! TestTarget
        let outputCopts = outputLib.copts.basic
        XCTAssertEqual(outputCopts?[0], "-initial")
        XCTAssertEqual(outputCopts?[1], "-foo")
        XCTAssertEqual(outputCopts?[2], "-bar")
    }

    func testUserOptionTransformGlobalCopts() {
        var target = TestTarget()
        target.copts = AttrSet(basic: ["-initial"])
        let attributes = UserConfigurableTargetAttributes(keyPathOperators:  ["TestTarget.copts += -foo, -bar"])
        let output = UserConfigurableTransform.executeUserOptionsTransform(onConvertibles: [target], copts: ["-boom"], userAttributes: attributes)
        let outputLib = output[0] as! TestTarget
        let outputCopts = outputLib.copts.basic
        XCTAssertEqual(outputCopts?[0], "-initial")
        XCTAssertEqual(outputCopts?[1], "-boom")
        XCTAssertEqual(outputCopts?[2], "-foo")
        XCTAssertEqual(outputCopts?[3], "-bar")
    }
}
