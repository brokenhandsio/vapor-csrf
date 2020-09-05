# Vapor CSRF

<p align="center">
    <img src="https://user-images.githubusercontent.com/9938337/92254623-14060f00-eec9-11ea-90e4-f6a52136aa67.png" alt="Vapor CSRF">
    <br>
    <br>
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

In simple terms it's tricking a user into making requests that a web application accepts. Imagine a bank website that has a POST request to transfer money into an account. If a malicious site can force the user to send that POST request (when they're logged in) then an attacker could trick a user into transferring money. 

CSRF tokens protects against this by ensuring the POST request is legitimate. The website provides a token to the GET request which it then checks when handling the POST request to ensure it matches.

Modern solutions such as [SameSite cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite) provide a similar protection but aren't supported on all browsers.

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
        // ..., 
        "VaporCSRF"]),
    // ...
]
```

## Usage

You must be using the `SessionsMiddleware` on all routes you interact with CSRF with. You can enable this globally in **configure.swift** with:

```swift
app.middleware.use(app.sessions.middleware)
```

For more information on sessions, [see the documentation](https://docs.vapor.codes/4.0/sessions/).

### GET routes

In GET routes that could return a POST request you want to protect, store a CSRF token in the session:

```swift
let csrfToken = req.csrf.storeToken()
```

This function returns a token you can then pass to your HTML page. For example, with Leaf this would look like:

```swift
let csrfToken = req.csrf.storeToken()
let context = MyPageContext(csrfToken: csrfToken)
return req.view.render("myPage", context)
```

You then need to return the token when the form is submitted. With Leaf, this would look something like:

```html
<form method="post">
    <input type="hidden" name="csrfToken" value="#(csrfToken)">
    <input type="submit" value="Submit">
</form>
```

### POST routes

You can protect your POST routes either with Middleware or manually verifying the token.

#### Middleware

VaporCSRF provides a middleware that checks the token for you. You can apply this to your routes with:

```swift
let csrfTokenPotectedRoutes = app.grouped(CSRFMiddleware())
```

#### Manual Verification

If you want to control when you verify the CSRF token, you can do this manually in your route handler with `try req.csrf.verifyToken()`. E.g.:

```swift
app.post("myForm") { req -> EventLoopFuture<Response> in
    try req.csrf.verifyToken()
    // ...
}
```

### Configuration

By default, VaporCSRF looks for a value with the key `csrfToken` in the POST body. You can change the key with:

```swift
app.csrf.setTokenContentKey("aDifferentKey")
```
