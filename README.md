# Vapor CSRF

<p align="center">
    <a href="https://vapor.codes">
        <img src="http://img.shields.io/badge/Vapor-4-brightgreen.svg" alt="Language">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/Swift-5.2-brightgreen.svg" alt="Language">
    </a>
    <a href="https://github.com/brokenhandsio/vapor-csrf/actions">
         <img src="https://github.com/brokenhandsio/vapor-csrf/workflows/CI/badge.svg?branch=main" alt="Build Status">
    <a href="https://codecov.io/gh/brokenhandsio/vapor-csrf">
        <img src="https://codecov.io/gh/brokenhandsio/vapor-csrf/branch/main/graph/badge.svg" alt="Code Coverage">
    </a>
    <a href="https://raw.githubusercontent.com/brokenhandsio/vapor-csrf/main/LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License">
    </a>
</p>

A simple library for protecting POST requests from CSRF (cross-site request forgery) attacks.

## What is CSRF?

In simple terms it's tricking a user into making requests that a web application accepts. Imagine a bank website that has a POST request to transfer money into an account. If a malicious site can force the user to send that POST request (when they're logged in) that an attacker could trick a user into transferring money. 

CSRF tokens protects against this by ensuring the POST request is legitimate. The website provides a token to the GET request which is then checks when handling the POST request to ensure it matches.

Modern solutions such as [SameSite cookies]() provide a similar protection but aren't supported on all browsers.

## Installation

Add the CSRF library in your dependencies array in **Package.swift**:

```swift
dependencies: [
    // ...,
    .package(name: "VaporCSRF", url: "https://github.com/brokenhandsio/vapor-csrf.git", from: "1.0.0")
],
```

Also ensure you add it as a dependency to your target:

```swift
targets: [
    .target(name: "App", dependencies: [
        .product(name: "Vapor", package: "vapor"), 
        ..., 
        "VaporCSRF"]),
    // ...
]
```

## Usage