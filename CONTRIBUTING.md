# How to Contribute

## Developer Certificate of Origin (DCO)

To maintain the ability to use this code in future versions or related projects, we require all contributions to be "signed off". This ensures that you have the right to submit the code and agree to the project's licensing.

By adding a `Signed-off-by` line to your commit message, you certify that you agree to the following:
* You created the contribution, or you have the right to submit it under the project's license.
* You understand that the project and the contribution are public and a record of the contribution (including your email) is maintained indefinitely.

### How to sign off
Simply add this line to the end of your commit message:
`Signed-off-by: Your Name <your.email@example.com>`

If you use Git via command line, you can do this automatically with:
`git commit -s -m "Your commit message"`

## Pull Requests

1. **Fork** the StarTools repository.
2. **Create a new branch** for each feature or improvement.
3. **Commit your changes** ensuring you include the `Signed-off-by` line.
4. **Send a pull request** from your feature branch to the **1.x** branch.

It is very important to separate new features or improvements into separate feature branches. This allows for individual review and testing.

## Style Guide (Quick Notes)

While the full guide is a TODO, please follow these basic rules:
* **PascalCase** for Class, Procedure and local variables names.
* **Indentation**: 2 spaces (Standard Lazarus/Delphi style).
* **Comments**: Use PasDoc `{* ... }` for public procedures and functions or for relevant private procedures.