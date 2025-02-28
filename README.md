# File Share Access Management GUI (FAMGUI)

A PowerShell-based graphical user interface tool for managing and viewing file share permissions across Windows directories. This tool provides an intuitive tree view of folder permissions, making it easier to audit and manage access controls.

## Features

- 🌳 Hierarchical tree view of folder permissions
- 📁 Recursive permission scanning
- 🔍 Detailed permission information including:
  - Identity/User references
  - Permission levels
  - Access types
  - Inheritance status
- 💻 User-friendly GUI interface
- 🔄 Real-time permission loading
- 📊 Clear permission hierarchy visualization

## Prerequisites

- Windows Operating System
- PowerShell 5.1 or higher
- Administrative privileges (for accessing certain directories)
- .NET Framework 4.5 or higher (for WPF support)

## Installation

1. Clone this repository or download the script files
2. Ensure PowerShell execution policy allows script execution:

## Usage

1. Run the script `FAMGUI_V1_Check_Users_Official.

2. Enter the path to the directory you want to analyze in the text box (default is "Z:\")
3. Click the "Load" button to scan the directory and its immediate subdirectories
4. Expand folders in the tree view to see detailed permissions

## Interface Guide

The interface consists of three main sections:

1. **Control Panel**

   - Text box for directory path input
   - Load button to initiate scanning

2. **Header Row**

   - Name: Identity or group name
   - Permission: Granted access rights
   - AccessType: Allow/Deny
   - IsInherited: Inheritance status

3. **Tree View**
   - Expandable folder nodes
   - Detailed permission entries under each folder

## Permissions Display

Each folder entry shows:

- 👤 Identity Reference (User/Group)
- 🔑 Permission Level
- ✅ Access Control Type
- 🔄 Inheritance Status

## Error Handling

The tool includes error handling for:

- Invalid directory paths
- Inaccessible directories
- Missing permissions
- Empty ACL lists

## Future Features

- 🔧 Permission Modification (Coming in V2)
  - Direct access right editing through the GUI
  - Batch permission updates
  - Change logging and audit trail
- 📋 Enhanced Reporting

  - Export permission reports to various formats

- Might consider creating a web interface

## Limitations

- Only scans the specified directory and its immediate subdirectories
- Requires appropriate permissions to access directories
- Performance may vary with large directory structures
- Windows-only compatibility

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Disclaimer

This project is a portfolio piece demonstrating automation and software development capabilities using standard Windows APIs and PowerShell commands. Please note:

- This is an educational project and should be used responsibly
- The code is provided "as-is" without any warranties or guarantees
- Users must ensure they have appropriate permissions and authorization before scanning or modifying any file systems
- The developer is not responsible for any unintended modifications to file permissions or access controls
- All sensitive information and company-specific implementations have been removed
- This is a generic implementation with no proprietary business logic
- The project should be used for learning and educational purposes only
- Always obtain proper authorization before deploying in a production environment
- Regular backups should be maintained before making any permission changes
- Users should thoroughly test in a non-production environment first

## Security Considerations

- The tool requires appropriate permissions to access directories
- Be cautious when examining sensitive directory structures
- No credentials or sensitive data are stored by the application

## Author

Liou Jun Yi

## Acknowledgments

- PowerShell Community
- Windows Presentation Foundation (WPF)
- .NET Framework

## Support

For issues, questions, or contributions, please:

1. Open an issue in the repository
2. Contact me at allenliou12@gmail.com

---

**Note**: This tool is designed for system administrators and users who need to manage and audit file share permissions. Always ensure you have appropriate access rights before scanning directories.
