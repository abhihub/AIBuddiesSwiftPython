#!/usr/bin/env python3
import re

# Read the project file
with open('AIBuddies.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Add SettingsView file reference
settings_file_ref = '\t\tOBJ_22 /* SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsView.swift; sourceTree = "<group>"; };'

# Insert the file reference after the last existing file reference
content = re.sub(
    r'(\t\tOBJ_21 /\* requirements\.txt \*/ = \{[^}]+\};\n)',
    r'\1' + settings_file_ref + '\n',
    content
)

# Add build file entry
settings_build_file = '\t\tOBJ_23 /* SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = OBJ_22 /* SettingsView.swift */; };'

# Insert the build file after the last existing build file
content = re.sub(
    r'(\t\tOBJ_16 /\* requirements\.txt in Resources \*/ = \{[^}]+\};\n)',
    r'\1' + settings_build_file + '\n',
    content
)

# Add to the group children
content = re.sub(
    r'(\t\t\t\tOBJ_19 /\* ChatManager\.swift \*/,\n)',
    r'\1\t\t\t\tOBJ_22 /* SettingsView.swift */,\n',
    content
)

# Add to sources phase
content = re.sub(
    r'(\t\t\t\tOBJ_14 /\* ChatManager\.swift in Sources \*/,\n)',
    r'\1\t\t\t\tOBJ_23 /* SettingsView.swift in Sources */,\n',
    content
)

# Write back to file
with open('AIBuddies.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("Successfully added SettingsView.swift to the Xcode project")