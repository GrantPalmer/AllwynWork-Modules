# Contributing Guidelines

Thank you for contributing to the Terraform Azure Modules repository! This document provides guidelines for contributing.

## Getting Started

### Prerequisites
- Git
- Terraform >= 1.0
- Azure CLI
- Code editor with Terraform support

### Development Setup
1. Fork the repository
2. Clone your fork locally
3. Create a feature branch
4. Make your changes
5. Test thoroughly
6. Submit a pull request

## Contribution Types

### New Modules
When creating a new module:
1. Follow the [module standards](./module-standards.md)
2. Use the standard file structure
3. Include comprehensive README
4. Add usage examples
5. Test in development environment

### Module Updates
For existing module updates:
1. Maintain backward compatibility when possible
2. Update version numbers appropriately
3. Update documentation
4. Test with existing implementations

### Bug Fixes
1. Create an issue first (if one doesn't exist)
2. Reference the issue in your PR
3. Include test cases
4. Provide clear description of the fix

## Development Standards

### Code Quality
- Use `terraform fmt` for formatting
- Pass `terraform validate`
- Follow naming conventions
- Add appropriate comments

### Testing
- Test in development environment
- Verify examples work
- Check for breaking changes
- Validate against multiple scenarios

### Documentation
- Update README.md files
- Include usage examples
- Document breaking changes
- Update version information

## Pull Request Process

### Before Submitting
1. Ensure your branch is up to date with main
2. Test your changes thoroughly
3. Update documentation
4. Follow commit message conventions

### PR Requirements
- Descriptive title and description
- Reference related issues
- Include testing details
- Add reviewer requests

### Commit Messages
Use conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Examples:
- `feat(storage): add support for blob containers`
- `fix(vm): resolve naming convention issue`
- `docs(readme): update usage examples`

### Types
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

## Review Process

### Reviewer Guidelines
- Check code quality and standards
- Verify documentation updates
- Test functionality when possible
- Provide constructive feedback

### Approval Process
1. Code review by module maintainers
2. Automated checks must pass
3. Testing verification
4. Final approval and merge

## Release Process

### Versioning
- Follow semantic versioning
- Tag releases appropriately
- Update changelog
- Communicate breaking changes

### Release Notes
Include:
- New features
- Bug fixes
- Breaking changes
- Migration guides

## Getting Help

### Communication Channels
- GitHub Issues for bugs/features
- Pull Request discussions
- Team collaboration tools

### Resources
- [Module Standards](./module-standards.md)
- [Usage Guide](./usage-guide.md)
- [Troubleshooting](./troubleshooting.md)
- Azure Documentation
- Terraform Documentation

## Code of Conduct

### Expected Behavior
- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Follow professional standards

### Unacceptable Behavior
- Harassment or discrimination
- Disrespectful communication
- Sharing sensitive information
- Violating security practices

## Security

### Reporting Security Issues
- Do not open public issues for security vulnerabilities
- Contact maintainers directly
- Provide detailed information
- Allow time for resolution

### Security Practices
- Never commit secrets or credentials
- Follow Azure security best practices
- Review code for security implications
- Keep dependencies updated

Thank you for contributing to making our Terraform modules better!
