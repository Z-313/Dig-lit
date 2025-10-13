#!/usr/bin/env python3
"""
Git Repository Fixer - Interactive Automation Script
Intelligently fixes common Git issues with natural language commands
"""

import subprocess
import os
import sys
import re
from pathlib import Path

class GitRepoFixer:
    def __init__(self):
        self.repo_path = os.getcwd()
        self.issues = []
        
    def run_command(self, cmd, capture=True):
        """Execute shell command and return output"""
        try:
            if capture:
                result = subprocess.run(
                    cmd, shell=True, capture_output=True, 
                    text=True, cwd=self.repo_path
                )
                return result.returncode, result.stdout, result.stderr
            else:
                result = subprocess.run(cmd, shell=True, cwd=self.repo_path)
                return result.returncode, "", ""
        except Exception as e:
            return 1, "", str(e)
    
    def diagnose_repo(self):
        """Analyze repository and identify issues"""
        print("🔍 Diagnosing repository...\n")
        
        # Check if it's a git repo
        code, out, err = self.run_command("git rev-parse --git-dir")
        if code != 0:
            print("❌ Not a Git repository!")
            return False
        
        # Check git status
        code, status_out, _ = self.run_command("git status --porcelain")
        
        # Check branches
        code, branch_out, _ = self.run_command("git branch -a")
        
        # Analyze issues
        self.issues = []
        
        if status_out:
            lines = status_out.strip().split('\n')
            untracked = [l for l in lines if l.startswith('??')]
            modified = [l for l in lines if l.startswith(' M') or l.startswith('M ')]
            deleted = [l for l in lines if l.startswith(' D') or l.startswith('D ')]
            added = [l for l in lines if l.startswith('A ')]
            
            if untracked:
                self.issues.append(('untracked', len(untracked), untracked))
            if modified:
                self.issues.append(('modified', len(modified), modified))
            if deleted:
                self.issues.append(('deleted', len(deleted), deleted))
            if added:
                self.issues.append(('added', len(added), added))
        
        # Check for large files
        code, out, _ = self.run_command("find . -type f -size +50M 2>/dev/null | grep -v '.git'")
        if out:
            large_files = out.strip().split('\n')
            self.issues.append(('large_files', len(large_files), large_files))
        
        # Display findings
        print("📊 Repository Status:")
        print(f"   Current branch: ", end="")
        code, branch, _ = self.run_command("git branch --show-current")
        print(branch.strip() if branch else "detached HEAD")
        
        if self.issues:
            print(f"\n⚠️  Found {len(self.issues)} types of issues:\n")
            for issue_type, count, items in self.issues:
                print(f"   • {issue_type.upper()}: {count} file(s)")
                for item in items[:3]:
                    print(f"      - {item[:80]}")
                if count > 3:
                    print(f"      ... and {count-3} more")
        else:
            print("\n✅ No issues found - repository is clean!")
        
        return True
    
    def fix_untracked(self):
        """Handle untracked files"""
        print("\n🔧 Fixing untracked files...")
        
        # Add .gitignore for common patterns
        gitignore_patterns = [
            "node_modules/",
            "*.log",
            ".env",
            ".DS_Store",
            "dist/",
            "build/",
            "__pycache__/",
            "*.pyc",
            ".vscode/",
            ".idea/"
        ]
        
        if not os.path.exists('.gitignore'):
            with open('.gitignore', 'w') as f:
                f.write('\n'.join(gitignore_patterns))
            print("   ✓ Created .gitignore with common patterns")
        
        self.run_command("git add .")
        print("   ✓ Staged all untracked files")
    
    def fix_modified(self):
        """Handle modified files"""
        print("\n🔧 Fixing modified files...")
        self.run_command("git add -u")
        print("   ✓ Staged all modified files")
    
    def fix_large_files(self):
        """Handle large files"""
        print("\n🔧 Handling large files...")
        print("   ⚠️  Large files detected. Consider:")
        print("      1. Adding them to .gitignore")
        print("      2. Using Git LFS (git lfs install)")
        print("   Skipping large file auto-fix for safety.")
    
    def commit_changes(self, message=None):
        """Commit staged changes"""
        if not message:
            message = "Auto-fix: Clean up repository"
        
        code, _, _ = self.run_command(f'git commit -m "{message}"')
        if code == 0:
            print(f"\n✅ Committed changes: {message}")
        else:
            print("\n⚠️  Nothing to commit or commit failed")
    
    def auto_fix(self):
        """Automatically fix all detected issues"""
        print("\n🤖 Starting auto-fix...\n")
        
        for issue_type, count, items in self.issues:
            if issue_type == 'untracked':
                self.fix_untracked()
            elif issue_type in ['modified', 'deleted', 'added']:
                self.fix_modified()
            elif issue_type == 'large_files':
                self.fix_large_files()
        
        # Commit if there are changes
        code, out, _ = self.run_command("git diff --cached --quiet")
        if code != 0:  # There are staged changes
            self.commit_changes()
    
    def interactive_mode(self):
        """Interactive command mode"""
        print("\n💬 Interactive Mode - Type commands in natural language")
        print("   Examples:")
        print("   - 'add all files'")
        print("   - 'commit with message: fixed bugs'")
        print("   - 'push to origin main'")
        print("   - 'create branch feature-xyz'")
        print("   - 'status' or 'diagnose'")
        print("   - 'exit' or 'quit'\n")
        
        while True:
            try:
                cmd = input("🔹 You: ").strip().lower()
                
                if not cmd:
                    continue
                
                if cmd in ['exit', 'quit', 'q']:
                    print("👋 Goodbye!")
                    break
                
                # Parse natural language commands
                if 'status' in cmd or 'diagnose' in cmd:
                    self.diagnose_repo()
                
                elif 'add all' in cmd or 'stage all' in cmd:
                    self.run_command("git add .")
                    print("   ✓ Staged all files")
                
                elif 'commit' in cmd:
                    # Extract message if provided
                    match = re.search(r'message[:\s]+(.+)', cmd)
                    msg = match.group(1) if match else "Auto commit"
                    self.commit_changes(msg)
                
                elif 'push' in cmd:
                    # Extract branch
                    match = re.search(r'to\s+(\w+)\s+(\w+)', cmd)
                    if match:
                        remote, branch = match.groups()
                        code, _, err = self.run_command(f"git push {remote} {branch}")
                        if code == 0:
                            print(f"   ✓ Pushed to {remote}/{branch}")
                        else:
                            print(f"   ❌ Push failed: {err}")
                    else:
                        print("   ⚠️  Specify: push to <remote> <branch>")
                
                elif 'pull' in cmd:
                    code, _, err = self.run_command("git pull")
                    if code == 0:
                        print("   ✓ Pulled latest changes")
                    else:
                        print(f"   ❌ Pull failed: {err}")
                
                elif 'create branch' in cmd or 'new branch' in cmd:
                    match = re.search(r'branch\s+(\S+)', cmd)
                    if match:
                        branch = match.group(1)
                        code, _, _ = self.run_command(f"git checkout -b {branch}")
                        if code == 0:
                            print(f"   ✓ Created and switched to branch: {branch}")
                    else:
                        print("   ⚠️  Specify branch name")
                
                elif 'switch' in cmd or 'checkout' in cmd:
                    match = re.search(r'(?:switch|checkout)\s+(?:to\s+)?(\S+)', cmd)
                    if match:
                        branch = match.group(1)
                        code, _, err = self.run_command(f"git checkout {branch}")
                        if code == 0:
                            print(f"   ✓ Switched to branch: {branch}")
                        else:
                            print(f"   ❌ Failed: {err}")
                
                elif 'fix' in cmd or 'auto' in cmd:
                    self.diagnose_repo()
                    self.auto_fix()
                
                elif 'help' in cmd:
                    print("""
   Available commands:
   - diagnose / status : Check repository status
   - add all : Stage all files
   - commit with message: <msg> : Commit changes
   - push to <remote> <branch> : Push changes
   - pull : Pull latest changes
   - create branch <name> : Create new branch
   - switch <branch> : Switch branches
   - fix / auto : Auto-fix all issues
   - exit / quit : Exit interactive mode
                    """)
                
                else:
                    print("   ❓ Command not recognized. Type 'help' for available commands")
            
            except KeyboardInterrupt:
                print("\n\n👋 Interrupted. Goodbye!")
                break
            except Exception as e:
                print(f"   ❌ Error: {e}")

def main():
    print("=" * 60)
    print("🔧 Git Repository Fixer - Digilit Project")
    print("=" * 60)
    
    fixer = GitRepoFixer()
    
    # Initial diagnosis
    if not fixer.diagnose_repo():
        sys.exit(1)
    
    # Ask user what to do
    print("\n" + "=" * 60)
    print("\nWhat would you like to do?")
    print("  1. Auto-fix all issues")
    print("  2. Interactive mode (natural language commands)")
    print("  3. Exit")
    
    choice = input("\nEnter choice (1-3): ").strip()
    
    if choice == '1':
        fixer.auto_fix()
        print("\n✨ Auto-fix complete!")
        fixer.diagnose_repo()
    elif choice == '2':
        fixer.interactive_mode()
    else:
        print("👋 Exiting...")

if __name__ == "__main__":
    main()