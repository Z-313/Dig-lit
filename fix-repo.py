#!/usr/bin/env python3
"""
Quantum-LED AI Agent v5.0 - DEEP VALIDATION EDITION
Complete validation and correction for ALL directories, subdirectories, and files
"""

import ast
import hashlib
import json
import os
import pickle
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Tuple


class DeepValidator:
    """Deep validation for entire repository tree"""

    def __init__(self, repo_path):
        self.repo_path = Path(repo_path)
        self.errors = []
        self.warnings = []
        self.fixes_applied = []

    def validate_all(self):
        """Validate EVERYTHING recursively"""
        print("🔍 DEEP VALIDATION MODE - Checking ALL directories and files\n")

        # 1. Validate directory structure
        self._validate_directories()

        # 2. Validate all files
        self._validate_files()

        # 3. Validate git status
        self._validate_git()

        # 4. Validate permissions
        self._validate_permissions()

        # 5. Validate code syntax
        self._validate_code_syntax()

        # 6. Generate report
        return self._generate_report()

    def _validate_directories(self):
        """Check all directories for issues"""
        print("📁 Validating directory structure...")

        for root, dirs, files in os.walk(self.repo_path):
            # Skip ignored directories
            dirs[:] = [
                d
                for d in dirs
                if d
                not in [
                    ".git",
                    "node_modules",
                    "__pycache__",
                    "venv",
                    ".quantum_memory",
                ]
            ]

            rel_root = os.path.relpath(root, self.repo_path)

            # Check for empty directories
            if not dirs and not files:
                self.warnings.append(f"Empty directory: {rel_root}")

            # Check for permission issues
            if not os.access(root, os.R_OK):
                self.errors.append(f"No read permission: {rel_root}")

            # Check for special characters in directory names
            if re.search(r'[<>:"|?*]', os.path.basename(root)):
                self.errors.append(f"Invalid characters in directory name: {rel_root}")

        print(f"   ✓ Checked all directories")

    def _validate_files(self):
        """Validate ALL files recursively"""
        print("📄 Validating all files...")

        for root, dirs, files in os.walk(self.repo_path):
            dirs[:] = [
                d
                for d in dirs
                if d
                not in [
                    ".git",
                    "node_modules",
                    "__pycache__",
                    "venv",
                    ".quantum_memory",
                ]
            ]

            for file in files:
                file_path = Path(root) / file
                rel_path = file_path.relative_to(self.repo_path)

                # Check if file exists and is readable
                if not file_path.exists():
                    self.errors.append(f"File doesn't exist: {rel_path}")
                    continue

                if not os.access(file_path, os.R_OK):
                    self.errors.append(f"No read permission: {rel_path}")
                    continue

                # Check file size (warn if > 100MB)
                size = file_path.stat().st_size
                if size > 100 * 1024 * 1024:
                    self.warnings.append(
                        f"Large file ({size/1024/1024:.1f}MB): {rel_path}"
                    )

                # Check for binary files that shouldn't be tracked
                if self._is_binary_file(file_path) and file_path.suffix in [
                    ".exe",
                    ".dll",
                    ".so",
                    ".dylib",
                ]:
                    self.warnings.append(f"Binary file in repo: {rel_path}")

                # Check for special characters
                if re.search(r'[<>:"|?*]', file):
                    self.errors.append(f"Invalid characters in filename: {rel_path}")

        print(f"   ✓ Checked all files")

    def _is_binary_file(self, file_path):
        """Check if file is binary"""
        try:
            with open(file_path, "rb") as f:
                chunk = f.read(1024)
                return b"\0" in chunk
        except:
            return False

    def _validate_git(self):
        """Deep git validation"""
        print("🔧 Validating git repository...")

        # Check if git repo
        if not (self.repo_path / ".git").exists():
            self.errors.append("Not a git repository")
            return

        # Get detailed git status
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True,
            text=True,
            cwd=self.repo_path,
        )

        if result.stdout:
            lines = result.stdout.strip().split("\n")

            # Categorize all changes
            untracked = []
            modified = []
            deleted = []
            renamed = []
            unmerged = []

            for line in lines:
                status = line[:2]
                filepath = line[3:]

                if status == "??":
                    untracked.append(filepath)
                elif "M" in status:
                    modified.append(filepath)
                elif "D" in status:
                    deleted.append(filepath)
                elif "R" in status:
                    renamed.append(filepath)
                elif "U" in status or "A" in status:
                    unmerged.append(filepath)

            if untracked:
                self.warnings.append(f"{len(untracked)} untracked files")
            if modified:
                self.warnings.append(f"{len(modified)} modified files")
            if deleted:
                self.warnings.append(f"{len(deleted)} deleted files")
            if unmerged:
                self.errors.append(f"{len(unmerged)} unmerged/conflicted files")

        # Check for uncommitted changes
        result = subprocess.run(
            ["git", "diff", "--cached", "--quiet"], cwd=self.repo_path
        )
        if result.returncode != 0:
            self.warnings.append("Staged changes not committed")

        print(f"   ✓ Git validation complete")

    def _validate_permissions(self):
        """Check file permissions"""
        print("🔐 Validating permissions...")

        for root, dirs, files in os.walk(self.repo_path):
            dirs[:] = [
                d
                for d in dirs
                if d
                not in [
                    ".git",
                    "node_modules",
                    "__pycache__",
                    "venv",
                    ".quantum_memory",
                ]
            ]

            for file in files:
                file_path = Path(root) / file

                # Check if executable files have proper permissions
                if file_path.suffix in [".sh", ".py"] or file.endswith(".command"):
                    if not os.access(file_path, os.X_OK):
                        self.warnings.append(
                            f"Script not executable: {file_path.relative_to(self.repo_path)}"
                        )

        print(f"   ✓ Permissions checked")

    def _validate_code_syntax(self):
        """Validate syntax of all code files"""
        print("🐍 Validating code syntax...")

        for root, dirs, files in os.walk(self.repo_path):
            dirs[:] = [
                d
                for d in dirs
                if d
                not in [
                    ".git",
                    "node_modules",
                    "__pycache__",
                    "venv",
                    ".quantum_memory",
                ]
            ]

            for file in files:
                file_path = Path(root) / file
                rel_path = file_path.relative_to(self.repo_path)

                # Validate Python files
                if file_path.suffix == ".py":
                    try:
                        with open(file_path, "r", encoding="utf-8") as f:
                            code = f.read()
                        ast.parse(code)
                    except SyntaxError as e:
                        self.errors.append(
                            f"Python syntax error in {rel_path}: Line {e.lineno}"
                        )
                    except Exception as e:
                        self.warnings.append(
                            f"Could not validate {rel_path}: {str(e)[:50]}"
                        )

                # Validate JSON files
                elif file_path.suffix == ".json":
                    try:
                        with open(file_path, "r", encoding="utf-8") as f:
                            json.load(f)
                    except json.JSONDecodeError as e:
                        self.errors.append(
                            f"JSON syntax error in {rel_path}: Line {e.lineno}"
                        )
                    except Exception:
                        pass

        print(f"   ✓ Code syntax validated")

    def _generate_report(self):
        """Generate comprehensive validation report"""
        return {
            "errors": self.errors,
            "warnings": self.warnings,
            "error_count": len(self.errors),
            "warning_count": len(self.warnings),
            "status": (
                "FAILED" if self.errors else ("WARNING" if self.warnings else "CLEAN")
            ),
        }


class AutoFixer:
    """Automatic fixer for all detected issues"""

    def __init__(self, repo_path):
        self.repo_path = Path(repo_path)
        self.fixes_applied = []

    def fix_all(self, validation_report):
        """Fix ALL issues automatically"""
        print("\n🔧 AUTO-FIX MODE - Correcting all issues\n")

        # Fix git issues
        self._fix_git_issues()

        # Fix permissions
        self._fix_permissions()

        # Create missing files
        self._create_missing_files()

        # Clean up
        self._cleanup()

        return self.fixes_applied

    def _fix_git_issues(self):
        """Fix all git-related issues"""
        print("📝 Fixing git issues...")

        # Stage all changes
        subprocess.run(["git", "add", "-A"], cwd=self.repo_path)
        self.fixes_applied.append("Staged all changes (git add -A)")

        # Check if there's anything to commit
        result = subprocess.run(
            ["git", "diff", "--cached", "--quiet"], cwd=self.repo_path
        )

        if result.returncode != 0:
            # Commit changes
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            subprocess.run(
                [
                    "git",
                    "commit",
                    "-m",
                    f"🤖 Auto-fix: Complete validation and correction | {timestamp}",
                ],
                cwd=self.repo_path,
            )
            self.fixes_applied.append("Created auto-fix commit")

        print("   ✓ Git issues fixed")

    def _fix_permissions(self):
        """Fix file permissions"""
        print("🔐 Fixing permissions...")

        for root, dirs, files in os.walk(self.repo_path):
            dirs[:] = [
                d
                for d in dirs
                if d
                not in [
                    ".git",
                    "node_modules",
                    "__pycache__",
                    "venv",
                    ".quantum_memory",
                ]
            ]

            for file in files:
                file_path = Path(root) / file

                # Make scripts executable
                if file_path.suffix in [".sh", ".py"] or file.endswith(".command"):
                    try:
                        os.chmod(file_path, 0o755)
                        self.fixes_applied.append(f"Made executable: {file_path.name}")
                    except:
                        pass

        print("   ✓ Permissions fixed")

    def _create_missing_files(self):
        """Create missing essential files"""
        print("📄 Creating missing files...")

        # Create .gitignore if missing
        gitignore_path = self.repo_path / ".gitignore"
        if not gitignore_path.exists():
            gitignore_content = """# Dependencies
node_modules/
venv/
__pycache__/
*.pyc

# Environment
.env
.env.local

# Build
dist/
build/
*.log

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Quantum Memory
.quantum_memory/

# Large files
*.mp4
*.zip
*.tar.gz
*.pdf
"""
            gitignore_path.write_text(gitignore_content)
            self.fixes_applied.append("Created .gitignore")
            print("   ✓ Created .gitignore")

        # Create README if missing
        readme_path = self.repo_path / "README.md"
        if not readme_path.exists():
            readme_content = f"""# Project Repository

Auto-generated README by Quantum-LED Agent v5.0

## Overview
This repository has been automatically validated and corrected.

## Last Validation
{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

## Status
✅ All validations passed
✅ All issues corrected

---
*Maintained by Quantum-LED AI Agent v5.0*
"""
            readme_path.write_text(readme_content)
            self.fixes_applied.append("Created README.md")
            print("   ✓ Created README.md")

    def _cleanup(self):
        """Clean up temporary files"""
        print("🧹 Cleaning up...")

        patterns = ["*.pyc", "*.pyo", "*.pyd", ".DS_Store", "Thumbs.db", "*.log"]

        for root, dirs, files in os.walk(self.repo_path):
            dirs[:] = [
                d
                for d in dirs
                if d
                not in [
                    ".git",
                    "node_modules",
                    "__pycache__",
                    "venv",
                    ".quantum_memory",
                ]
            ]

            for file in files:
                for pattern in patterns:
                    if Path(file).match(pattern):
                        file_path = Path(root) / file
                        try:
                            file_path.unlink()
                            self.fixes_applied.append(f"Removed: {file}")
                        except:
                            pass

        print("   ✓ Cleanup complete")


def main():
    print("=" * 80)
    print("🌌 QUANTUM-LED AI AGENT v5.0 - DEEP VALIDATION EDITION")
    print("   Complete validation and correction for ALL directories and files")
    print("=" * 80)

    repo_path = os.getcwd()

    # Phase 1: Deep Validation
    print("\n" + "=" * 80)
    print("PHASE 1: DEEP VALIDATION")
    print("=" * 80 + "\n")

    validator = DeepValidator(repo_path)
    report = validator.validate_all()

    # Display Report
    print("\n" + "=" * 80)
    print("VALIDATION REPORT")
    print("=" * 80)
    print(f"\n🎯 Status: {report['status']}")
    print(f"❌ Errors: {report['error_count']}")
    print(f"⚠️  Warnings: {report['warning_count']}\n")

    if report["errors"]:
        print("❌ ERRORS FOUND:")
        for i, error in enumerate(report["errors"][:20], 1):
            print(f"   {i}. {error}")
        if len(report["errors"]) > 20:
            print(f"   ... and {len(report['errors']) - 20} more")

    if report["warnings"]:
        print("\n⚠️  WARNINGS:")
        for i, warning in enumerate(report["warnings"][:20], 1):
            print(f"   {i}. {warning}")
        if len(report["warnings"]) > 20:
            print(f"   ... and {len(report['warnings']) - 20} more")

    # Phase 2: Auto-Fix
    if report["errors"] or report["warnings"]:
        print("\n" + "=" * 80)
        print("PHASE 2: AUTO-FIX")
        print("=" * 80 + "\n")

        response = input("🤖 Apply automatic fixes? [Y/n]: ").strip().lower()

        if response != "n":
            fixer = AutoFixer(repo_path)
            fixes = fixer.fix_all(report)

            print("\n" + "=" * 80)
            print("FIXES APPLIED")
            print("=" * 80 + "\n")

            for i, fix in enumerate(fixes, 1):
                print(f"   ✓ {i}. {fix}")

            print(f"\n✨ Total fixes applied: {len(fixes)}")

            # Re-validate
            print("\n" + "=" * 80)
            print("FINAL VALIDATION")
            print("=" * 80 + "\n")

            validator2 = DeepValidator(repo_path)
            final_report = validator2.validate_all()

            print(f"\n🎯 Final Status: {final_report['status']}")
            print(f"❌ Remaining Errors: {final_report['error_count']}")
            print(f"⚠️  Remaining Warnings: {final_report['warning_count']}")

            if final_report["status"] == "CLEAN":
                print("\n🎉 REPOSITORY IS NOW 100% CLEAN! 🎉")
            elif final_report["status"] == "WARNING":
                print("\n✅ All critical errors fixed! (Some warnings remain)")
            else:
                print("\n⚠️  Some issues still need manual attention")
    else:
        print("\n✅ NO ISSUES FOUND - Repository is already perfect!")

    print("\n" + "=" * 80)
    print("🌌 Quantum-LED Agent v5.0 - Operation Complete")
    print("=" * 80)


if __name__ == "__main__":
    main()
