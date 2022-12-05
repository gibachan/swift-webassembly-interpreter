//
//  Plugin.swift
//
//
//  Created by Tatsuyuki Kobayashi on 2022/12/05.
//

import Foundation
import PackagePlugin

@main
struct Plugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let swiftlint = try context.tool(named: "swiftlint")
        let arguments = [
            "--config", "\(context.package.directory.string)/.swiftlint.yml",
            "--no-cache",
        ]

        return [
            .buildCommand(
                displayName: "SwiftLint",
                executable: swiftlint.path,
                arguments: arguments,
                environment: [:]
            )
        ]
    }
}
